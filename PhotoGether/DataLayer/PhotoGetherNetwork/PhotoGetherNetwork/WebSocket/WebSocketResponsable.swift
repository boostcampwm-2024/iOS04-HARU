import Foundation

public protocol WebSocketResponsable: Decodable {
    associatedtype ResponseType: Decodable
    var messageType: ResponseType { get }
    var message: Data? { get }
}
