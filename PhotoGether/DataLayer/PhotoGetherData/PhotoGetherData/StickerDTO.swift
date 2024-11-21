import Foundation
import PhotoGetherDomainInterface

public struct StickerDTO: Decodable {
    let code: String
    let character: String
    let image: String
    let name: String
    let group: String
    let subgroup: String
}

extension StickerDTO {
    func toEntity() -> StickerEntity {
        return .init(
            image: self.image,
            name: self.name
        )    
    }
}
