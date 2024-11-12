import Foundation

public protocol WebSocketClient {
    var delegate: WebSocketClientDelegate? { get }
    
    func connect()
    func send(data: Data)
}
