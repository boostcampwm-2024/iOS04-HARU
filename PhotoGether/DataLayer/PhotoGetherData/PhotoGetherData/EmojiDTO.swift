import Foundation
import PhotoGetherDomainInterface

public struct EmojiDTO: Decodable {
    let code: String
    let character: String
    let image: String
    let name: String
    let group: String
    let subgroup: String
}

extension EmojiDTO {
    func toEntity() -> EmojiEntity {
        return .init(
            image: self.image,
            name: self.name
        )    
    }
}
