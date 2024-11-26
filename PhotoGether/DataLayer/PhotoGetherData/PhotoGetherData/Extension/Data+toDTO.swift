import Foundation

public extension Data {
    func toDTO<T: Decodable>(type: T.Type, decoder: JSONDecoder) -> T? {
        return try? decoder.decode(type, from: self)
    }
}
