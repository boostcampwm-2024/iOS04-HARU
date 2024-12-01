import Foundation

public struct EmojiEntity: Decodable {
    public let image: String
    public let name: String

    public init(image: String, name: String) {
        self.image = image
        self.name = name
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
