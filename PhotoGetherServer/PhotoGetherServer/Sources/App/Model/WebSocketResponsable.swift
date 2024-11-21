import Foundation

public protocol WebSocketResponsable: Encodable {
    associatedtype RequestType: Encodable
    var messageType: RequestType { get }
    var message: Data? { get }
    
    func toData(encoder: JSONEncoder) -> Data?
}

public extension WebSocketResponsable {
    func toData(encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}
