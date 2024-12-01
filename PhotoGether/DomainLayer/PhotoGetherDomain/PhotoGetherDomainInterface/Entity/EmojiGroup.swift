import Foundation

public enum EmojiGroup: CustomStringConvertible {
    case smileysEmotion
    case animalsNature
    case foodDrink
    case travelPlaces
    case activity
    case objects
    case symbols
    
    public var description: String {
        switch self {
        case .smileysEmotion: return "smileys-emotion"
        case .animalsNature: return "animals-nature"
        case .foodDrink: return "food-drink"
        case .travelPlaces: return "travel-places"
        case .activity: return "activity"
        case .objects: return "objects"
        case .symbols: return "symbols"
        }
    }
}
