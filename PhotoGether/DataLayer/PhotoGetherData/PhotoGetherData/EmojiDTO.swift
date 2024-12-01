import Foundation
import PhotoGetherDomainInterface

public struct EmojiDTO: Codable {
    let emoji, hexcode: String
    let group: EmojiGroup
    let subgroup: String
    let annotation: String
    let tags, shortcodes, emoticons: [String]
    let directional, variation: Bool
    let variationBase: Bool?
    let unicode: Double
    let order: Int
    let skintone: Int?
    let skintoneCombination, skintoneBase: String?
}


extension EmojiDTO {
    func toEntity() -> EmojiEntity {
        return .init(
            emoji: emoji,
            hexCode: hexcode,
            group: group,
            annotation: annotation
        )
    }
}
