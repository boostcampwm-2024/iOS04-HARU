import Foundation

public protocol WebSocketRequestable: Encodable {
    associatedtype RequestType: Encodable
    var messageType: RequestType { get }
    var message: Data? { get }
}
