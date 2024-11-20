import Foundation

public extension Data {
    func convert(to type: Decodable.Type) -> Decodable? {
        return try? JSONDecoder().decode(type, from: self)
    }
}
