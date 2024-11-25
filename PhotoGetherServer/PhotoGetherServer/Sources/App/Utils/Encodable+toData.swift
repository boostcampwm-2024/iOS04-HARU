import Foundation

extension Encodable {
    func toData(_ encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}
