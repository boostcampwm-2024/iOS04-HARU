import Foundation
import PhotoGetherNetwork
import PhotoGetherDomainInterface

public final class RoomServiceImpl: RoomService {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var webSocketClient: WebSocketClient
    
    public init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
    }
    
    public func send(request: Encodable) {
        guard let request = request as? (any WebSocketRequestable),
                let data = request.toData(encoder: encoder) else {
            debugPrint("방 생성 요청 데이터 인코딩 실패: \(request)")
            return
        }
        
        webSocketClient.send(data: data)
    }
}

// MARK: WebSocketDelegate
extension RoomServiceImpl: WebSocketClientDelegate {
    public func webSocketDidConnect(_ webSocket: WebSocketClient) { }
    
    public func webSocketDidDisconnect(_ webSocket: WebSocketClient) { }
    
    public func webSocket(_ webSocket: WebSocketClient, didReceiveData data: Data) {
        // TODO: 생성된 방번호 고유 아이디가 담긴 정보 디코딩
        // data Response DTO -> 한번 디코딩하고 타입 확인
        guard let response = data.toDTO(type: RoomResponseDTO.self) else { return }
        
        switch response.messageType {
        case .createRoom:
            guard let message = response.message else { return }
            guard let message = message.toDTO(type: CreateRoomMessage.self) else {
                debugPrint("Decode Failed to CreateRoomMessage: \(message)")
                return
            }
            debugPrint("방 생성 성공: \(message.roomID) \n 유저 아이디: \(message.userID)")
        case .joinRoom:
            break
        }
    }
}
