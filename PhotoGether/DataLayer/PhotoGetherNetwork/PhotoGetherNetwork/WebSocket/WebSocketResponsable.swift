import Foundation

public protocol WebSocketResponsable: Decodable {
    associatedtype ResponseType: Decodable
    var type: ResponseType { get }
    var message: Data? { get }
}
