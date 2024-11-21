import Foundation

public protocol WebSocketRequestable: Decodable {
    associatedtype ResponseType: Decodable
    var messageType: ResponseType { get }
    var message: Data? { get }
}
