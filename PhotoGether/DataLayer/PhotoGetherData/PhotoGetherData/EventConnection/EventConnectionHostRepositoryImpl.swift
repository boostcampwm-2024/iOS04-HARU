import Foundation
import Combine
import PhotoGetherDomainInterface

public final class EventConnectionHostRepositoryImpl: EventConnectionRepository {
    public var clients: [ConnectionClient]
    private let eventHub = EventHub()
    private var cancellables: Set<AnyCancellable> = []
    private var receiveDataFromGuest = PassthroughSubject<Data, Never>()
    private var sendToViewModel = PassthroughSubject<[StickerEntity], Never>()
    
    public init(clients: [ConnectionClient]) {
        self.clients = clients
        bindData()
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
        eventHub.resultEventPublisher
            .sink { [weak self] entityList in
                guard let encodedData = try? entityList.encode() else { return }
                print("DEBUG: EventHub Result Send")
                self?.clients.forEach { $0.sendData(data: encodedData)}
                self?.sendToViewModel.send(entityList)
            }
            .store(in: &cancellables)
    }
    
    // MARK: 호스트는 EventType도 얘를 호출하는애가 넣어줘야한다.
    public func receiveStickerList() -> AnyPublisher<[StickerEntity], Never> {
        return sendToViewModel.eraseToAnyPublisher()
    }
    
    public func mergeSticker(type: EventType, sticker: StickerEntity) {
        let sticketEvent = EventEntity(
            type: type,
            timeStamp: Date(),
            entity: EntityType.sticker(sticker)
        )
        eventHub.push(event: sticketEvent)
    }
}
