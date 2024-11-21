import Foundation
import Combine
import PhotoGetherDomainInterface

public final class EventConnectionHostRepositoryImpl {
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
                self?.receiveDataFromGuest.send(data)
            }
            .store(in: &cancellables)
        }
        
        // MARK: 그럼 Host기준 게스트로부터 받은 데이터는 모두 EventHub를 거친다
        receiveDataFromGuest
            .sink { [weak self] data in
            // TODO: Data를 EventEntity로 디코딩해서 EventHub에 push
//            eventHub.push(event: )
            }
            .store(in: &cancellables)
        
        // MARK: EventHub에서 처리된 Event를 (GuestClient + HostView)에게 전파한다.
        eventHub.resultEventPublisher
            .sink { [weak self] enitityList in
                let encodedData = Data()
                self?.clients.forEach { $0.sendData(data: encodedData)}
                // 자기 뷰에 보내기
                self?.sendToViewModel.send([])
            }
            .store(in: &cancellables)
    }
    
    // MARK: 호스트는 EventType도 얘를 호출하는애가 넣어줘야한다.
    func mergeSticker(sticker: StickerEntity) {
        let sticketEvent = EventEntity(type: .create, timeStamp: Date(), entity: sticker)
        eventHub.push(event: sticketEvent)
    }
    
    func fetchStickerList() -> AnyPublisher<[StickerEntity], Never> {
        return sendToViewModel.eraseToAnyPublisher()
    }
}
