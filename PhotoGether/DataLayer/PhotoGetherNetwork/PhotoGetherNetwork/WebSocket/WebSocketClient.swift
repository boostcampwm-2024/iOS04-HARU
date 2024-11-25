import Foundation

public protocol WebSocketClient {
    var delegates: [WebSocketClientDelegate] { get set }
    
    func connect()
    func send(data: Data)
}
