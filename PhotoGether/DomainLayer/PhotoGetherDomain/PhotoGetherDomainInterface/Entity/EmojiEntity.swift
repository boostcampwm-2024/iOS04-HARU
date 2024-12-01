import Foundation

public struct EmojiEntity: Decodable {
    public let emoji: String
    public let hexCode: String
    public let group: EmojiGroup
    public let annotation: String
    public var emojiURL: URL? {
        guard let emojiURL = URL(string: "https://www.emoji.family/api/emojis")
        else { return nil }
        
        let style = emojiStyle.blobmoji.rawValue
        let ext = "png"
        let size = "96"
        
        return emojiURL
            .appendingPathComponent(hexCode)
            .appendingPathComponent(style)
            .appendingPathComponent(ext)
            .appendingPathComponent(size)
    }
    
    public init(
        emoji: String,
        hexCode: String,
        group: EmojiGroup,
        annotation: String
    ) {
        self.emoji = emoji
        self.hexCode = hexCode
        self.group = group
        self.annotation = annotation
    }
    
    private enum emojiStyle: String {
        case noto, twemoji, openmoji, blobmoji, fluent, fluentflat
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
