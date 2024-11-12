import Foundation

public protocol WebSocketClientDelegate: AnyObject {
    func webSocketDidConnect(_ webSocket: WebSocketClient)
    func webSocketDidDisconnect(_ webSocket: WebSocketClient)
    func webSocket(_ webSocket: WebSocketClient, didReceiveData data: Data)
}
