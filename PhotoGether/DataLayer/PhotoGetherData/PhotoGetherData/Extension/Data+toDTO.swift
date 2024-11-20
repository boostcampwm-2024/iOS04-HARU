import Foundation

extension Data {
    func toDTO(type: Decodable.Type) -> Decodable? {
        return try? JSONDecoder().decode(type, from: self)
    }
}
