import Foundation
import Combine
import PhotoGetherDomainInterface

public final class EventConnectionHostRepositoryImpl: EventConnectionRepository {
    private let clients: [ConnectionClient]
    
    private let eventHub = EventHub()
    
    private let receiveDataFromGuest = PassthroughSubject<Data, Never>()
    private let sendToViewModel = PassthroughSubject<[StickerEntity], Never>()
    private let sendToViewModelFrame = PassthroughSubject<FrameEntity, Never>()
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(clients: [ConnectionClient]) {
        self.clients = clients
        setupCoder()
        bindData()
    }
    
    private func setupCoder() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }
    
    private func bindData() {
        clients.forEach {
            $0.receivedDataPublisher.sink { [weak self] data in
                print("DEBUG: Data Receive From Guest")
                self?.receiveDataFromGuest.send(data)
            }
            .store(in: &cancellables)
        }
        
        // MARK: 그럼 Host기준 게스트로부터 받은 데이터는 모두 EventHub를 거친다
        receiveDataFromGuest
            .sink { [weak self] data in
            // TODO: Data를 EventEntity로 디코딩해서 EventHub에 push
                print("DEBUG: Push Event Hub")
                guard let eventEntity = try? EventEntity.decode(from: data) else { return }
                self?.eventHub.push(event: eventEntity)
            }
            .store(in: &cancellables)
        
        // MARK: EventHub에서 처리된 Event를 (GuestClient + HostView)에게 전파한다.
        eventHub.stickerListPublisher
            .sink { [weak self] entityList in
                let payload = EventPayload.stickerList(entityList)
                guard let encodedData = try? self?.encoder.encode(payload) else { return }
                print("DEBUG: EventHub Result Send")
                self?.clients.forEach { $0.sendData(data: encodedData)}
                self?.sendToViewModel.send(entityList)
            }
            .store(in: &cancellables)
        
        eventHub.framePublisher
            .sink { [weak self] frameEntity in
                let payload = EventPayload.frame(frameEntity)
                guard let encodedData = try? self?.encoder.encode(payload) else { return }
                self?.clients.forEach { $0.sendData(data: encodedData) }
                self?.sendToViewModelFrame.send(frameEntity)
            }
            .store(in: &cancellables)
    }
    
    // MARK: 호스트는 EventType도 얘를 호출하는애가 넣어줘야한다.
    public func receiveStickerList() -> AnyPublisher<[StickerEntity], Never> {
        return sendToViewModel.eraseToAnyPublisher()
    }
    
    public func mergeSticker(type: EventType, sticker: StickerEntity) {
        let stickerEvent = EventEntity(
            type: type,
            timeStamp: Date(),
            payload: EventPayload.sticker(sticker)
        )
        eventHub.push(event: stickerEvent)
    }
    
    public func receiveFrameEntity() -> AnyPublisher<FrameEntity, Never> {
        return sendToViewModelFrame.eraseToAnyPublisher()
    }
    
    public func mergeFrame(type: EventType, frame: FrameEntity) {
        let frameEvent = EventEntity(
            type: type,
            timeStamp: Date(),
            payload: EventPayload.frame(frame)
        )
        eventHub.push(event: frameEvent)
    }
}
