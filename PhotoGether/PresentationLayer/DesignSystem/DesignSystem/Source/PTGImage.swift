import UIKit

public enum PTGImage {
    case frameIcon
    case stickerIcon
    case chevronLeftWhite
    case chevronRightBlack
    case sampleImage
    case filterIcon
    case switchIcon
    case temp3, temp4
    
    public var image: UIImage {
        switch self {
        case .frameIcon:
            return UIImage(resource: .frameIcon)
        case .stickerIcon:
            return UIImage(resource: .stickerIcon)
        case .chevronLeftWhite:
            return UIImage(resource: .chevronLeftWhite)
        case .chevronRightBlack:
            return UIImage(resource: .chevronRightBlack)
        case .sampleImage:
            return UIImage(resource: .sample)
        case .filterIcon:
            return UIImage(resource: .filterIcon)
        case .switchIcon:
            return UIImage(resource: .switchIcon)
        case .temp3:
            return UIImage(resource: .temp3)
        case .temp4:
            return UIImage(resource: .temp4)
        }
    }
}
