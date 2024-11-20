import Foundation

public protocol WebSocketRequestable: Encodable {
    associatedtype RequestType: Encodable
    var type: RequestType { get }
    var message: Data? { get }
    
    func toData(encoder: JSONEncoder) -> Data?
}

public extension WebSocketRequestable {
    func toData(encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}
