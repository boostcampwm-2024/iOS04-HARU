import UIKit

public enum PTGImage {
    case frameIcon
    case stickerIcon
    
    public var image: UIImage {
        switch self {
        case .frameIcon:
            return UIImage(resource: .frameIcon)
        case .stickerIcon:
            return UIImage(resource: .stickerIcon)
        }
    }
}
