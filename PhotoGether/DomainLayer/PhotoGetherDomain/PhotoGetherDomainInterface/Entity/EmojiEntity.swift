import Foundation

public struct EmojiEntity: Decodable {
    public let emoji: String
    public let group: EmojiGroup
    public let annotation: String

    public init(
        emoji: String,
        group: EmojiGroup,
        annotation: String
    ) {
        self.emoji = emoji
        self.group = group
        self.annotation = annotation
    }
}

public enum EmojiGroup: String, Codable {
    case smileysEmotion = "smileys-emotion"
    case peopleBody = "people-body"
    case component = "component"
    case animalsNature = "animals-nature"
    case foodDrink = "food-drink"
    case travelPlaces = "travel-places"
    case activities = "activities"
    case objects = "objects"
    case symbols = "symbols"
}
