import Foundation

extension Encodable {
    func toData(encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}
