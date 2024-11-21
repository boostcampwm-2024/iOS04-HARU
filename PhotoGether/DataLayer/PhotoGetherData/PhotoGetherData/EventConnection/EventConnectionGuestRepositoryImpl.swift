import Foundation
import Combine
import PhotoGetherDomainInterface

public final class EventConnectionGuestRepositoryImpl {
    public var clients: [ConnectionClient]
    private var cancellables: Set<AnyCancellable> = []
    private var receiveDataFromHost = PassthroughSubject<Data, Never>()
    
    public init(clients: [ConnectionClient]) {
        self.clients = clients
        bindData()
    }
    
    private func bindData() {
        // MARK: Host로 부터 들어오는 Data를 send한다.
        // clients.filter { $0 == .host }
        // receiveDataFromHost.send(Data())
    }
    
    // MARK: 게스트가 호스트에게 스티커의 생성/삭제/이동 등 이벤트 전달
    func mergeSticker(sticker: StickerEntity) {
        let sticketEvent = EventEntity(type: .create, timeStamp: Date(), entity: sticker)
        // MARK: Host의 Client를 특정한다.
        // clients.filter { $0 == .host }
        // 자신의 이벤트를 전달한다. // MARK: hostClient.sendData()
    }
    
    func fetchStickerList() -> AnyPublisher<[StickerEntity], Error> {
        return receiveDataFromHost
            .decode(type: [StickerEntity].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
