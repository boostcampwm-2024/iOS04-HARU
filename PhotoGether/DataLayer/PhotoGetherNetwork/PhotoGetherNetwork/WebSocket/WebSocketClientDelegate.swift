import Foundation

@available(*, deprecated, message: "Publisher로 교체될 예정입니다.")
public protocol WebSocketClientDelegate: AnyObject {
    func webSocketDidConnect(_ webSocket: WebSocketClient)
    func webSocketDidDisconnect(_ webSocket: WebSocketClient)
    func webSocket(_ webSocket: WebSocketClient, didReceiveData data: Data)
}
