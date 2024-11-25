import Foundation
import Combine
import PhotoGetherDomainInterface

public final class EventConnectionGuestRepositoryImpl: EventConnectionRepository {
    public var clients: [ConnectionClient]
    private var cancellables: Set<AnyCancellable> = []
    private let receiveDataFromHost = PassthroughSubject<[StickerEntity], Never>()
    private let receiveDataFromHostFrame = PassthroughSubject<FrameEntity, Never>()
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
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
        // MARK: Host로 부터 들어오는 Data를 send한다.
        // clients.filter { $0 == .host }
        // receiveDataFromHost.send(Data())
        
        clients.first?.receivedDataPublisher
            .sink(receiveValue: { [weak self] data in
                guard let payload = try? self?.decoder.decode(EventPayload.self, from: data) else { return }
                
                switch payload {
                case .stickerList(let stickerList):
                    print("DEBUG: Decoded Sticker List: \(stickerList)")
                    self?.receiveDataFromHost.send(stickerList)
                case .frame(let frameEntity):
                    print("DEBUG: Decoded Frame Entity: \(frameEntity)")
                    self?.receiveDataFromHostFrame.send(frameEntity)
                default:
                    break
                }
            })
            .store(in: &cancellables)
    }
    
    // MARK: 게스트가 호스트에게 스티커의 생성/삭제/이동 등 자신의 이벤트를 전달
    public func mergeSticker(type: EventType, sticker: StickerEntity) {
        let stickerEvent = EventEntity(
            type: type,
            timeStamp: Date(),
            payload: EventPayload.sticker(sticker)
        )
        
        guard let encodedStickerEvent = try? stickerEvent.encode() else { return }
        
        // MARK: Host의 Client를 특정한다.
        // clients.filter { $0 == .host }
        
        // 자신의 이벤트를 전달한다. // MARK: hostClient.sendData()
        clients.first?.sendData(data: encodedStickerEvent)
    }
    
    public func receiveStickerList() -> AnyPublisher<[StickerEntity], Never> {
        return receiveDataFromHost
            .decode(type: [StickerEntity].self, decoder: decoder)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}
