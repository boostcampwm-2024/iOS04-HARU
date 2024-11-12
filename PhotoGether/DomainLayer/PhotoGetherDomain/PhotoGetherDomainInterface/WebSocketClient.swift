import Foundation

public protocol WebSocketClient {
    var delegate: WebSocketClientDelegate? { get set }
    
    func connect()
    func send(data: Data)
}
