import Foundation

public extension Data {
    func toDTO<T: Decodable>(type: T.Type) -> T? {
        return try? JSONDecoder().decode(type, from: self)
    }
}
