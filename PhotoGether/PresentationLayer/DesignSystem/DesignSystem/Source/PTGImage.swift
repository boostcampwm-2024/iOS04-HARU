import UIKit

public enum PTGImage {
    case frameIcon
    case stickerIcon
    case chevronLeftWhite
    case chevronRightBlack
    case sampleImage
    case temp1, temp2, temp3, temp4
    case temp5, temp6, temp7, temp8
    case temp9, temp10, temp11, temp12
    case filterIcon
    case switchIcon
    case ellipsisIcon
    case xmarkIcon
    
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
        case .temp1:
            return UIImage(resource: .temp1)
        case .temp2:
            return UIImage(resource: .temp2)
        case .temp3:
            return UIImage(resource: .temp3)
        case .temp4:
            return UIImage(resource: .temp4)
        case .temp5:
            return UIImage(resource: .temp5)
        case .temp6:
            return UIImage(resource: .temp6)
        case .temp7:
            return UIImage(resource: .temp7)
        case .temp8:
            return UIImage(resource: .temp8)
        case .temp9:
            return UIImage(resource: .temp9)
        case .temp10:
            return UIImage(resource: .temp10)
        case .temp11:
            return UIImage(resource: .temp11)
        case .temp12:
            return UIImage(resource: .temp12)
        case .filterIcon:
            return UIImage(resource: .filterIcon)
        case .switchIcon:
            return UIImage(resource: .switchIcon)
        case .ellipsisIcon:
            return UIImage(resource: .ellipsisIcon)
        case .xmarkIcon:
            return UIImage(resource: .ptGxmark)
        }
    }
}
