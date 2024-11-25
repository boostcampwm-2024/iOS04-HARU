import Foundation
import Combine

public protocol WebSocketClient {
    var delegates: [WebSocketClientDelegate] { get set }
    var webSocketDidConnectPublisher: AnyPublisher<Void, Never> { get }
    var webSocketDidDisconnectPublisher: AnyPublisher<Void, Never> { get }
    var webSocketdidReceiveDataPublisher: AnyPublisher<Data, Never> { get }
    
    func connect()
    func send(data: Data)
}
