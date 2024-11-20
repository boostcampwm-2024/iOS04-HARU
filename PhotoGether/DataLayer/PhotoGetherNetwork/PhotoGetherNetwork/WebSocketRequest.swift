import Foundation

public struct WebSocketRequest: Encodable {
    let type: String
    
    public func toData(encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}
