import Foundation
import Combine
import PhotoGetherNetwork
import PhotoGetherDomainInterface

public final class RoomServiceImpl: RoomService {
    public var createRoomResponsePublisher: AnyPublisher<CreateRoomEntity, Error> {
        _createRoomResponsePublisher.eraseToAnyPublisher()
    }
    private let _createRoomResponsePublisher = PassthroughSubject<CreateRoomEntity, Error>()
    private var cancellables: Set<AnyCancellable> = []
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var webSocketClient: WebSocketClient
    
    public init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
        bindWebSocketClient()
    }
    
    public func createRoom() -> AnyPublisher<CreateRoomEntity, Error> {
        let createRoomRequest = RoomRequestDTO(messageType: .createRoom)
        
        guard let data = createRoomRequest.toData(encoder: encoder) else {
            debugPrint("방 생성 요청 데이터 인코딩 실패: \(createRoomRequest)")
            return Fail(error: RoomServiceError.failedToEncoding).eraseToAnyPublisher()
        }
        
        webSocketClient.send(data: data)
        return createRoomResponsePublisher
    }
    
    public func joinRoom() { }
    
    private func bindWebSocketClient() {
        self.webSocketClient.webSocketdidReceiveDataPublisher
            .sink { [weak self] data in
                guard let self else { return }
                
                guard let response = data.toDTO(type: RoomResponseDTO.self) else { return }
                
                switch response.messageType {
                case .createRoom:
                    guard let message = response.message else { return }
                    guard let message = message.toDTO(type: CreateRoomMessage.self) else {
                        debugPrint("Decode Failed to CreateRoomMessage: \(message)")
                        return
                    }
                    let createRoomEntity = CreateRoomEntity(roomID: message.roomID, userID: message.userID)
                    _createRoomResponsePublisher.send(createRoomEntity)
                    
                    debugPrint("방 생성 성공: \(message.roomID) \n 유저 아이디: \(message.userID)")
                case .joinRoom:
                    break
                }
            }.store(in: &cancellables)
    }
}

public enum RoomServiceError: LocalizedError {
    case failedToEncoding
    
    public var errorDescription: String? {
        switch self {
        case .failedToEncoding:
            return "Failed to encode room service request"
        }
    }
}
