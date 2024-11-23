import Foundation
import PhotoGetherNetwork

public final class RoomServiceImpl: RoomService {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var webSocketClient: WebSocketClient
    
    public init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
    }
    
    public func send(request: any WebSocketRequestable) {
        guard let data = request.toData(encoder: encoder) else {
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
    }
}
