import UIKit

public enum PTGColor {
    case gray10
    case gray20
    case gray30
    case gray40
    case gray50
    case gray60
    case gray70
    case gray80
    case gray85
    case gray90
    case primaryGreen
    
    public var color: UIColor {
        switch self {
        case .gray10: return UIColor(resource: .gray10)
        case .gray20: return UIColor(resource: .gray20)
        case .gray30: return UIColor(resource: .gray30)
        case .gray40: return UIColor(resource: .gray40)
        case .gray50: return UIColor(resource: .gray50)
        case .gray60: return UIColor(resource: .gray60)
        case .gray70: return UIColor(resource: .gray70)
        case .gray80: return UIColor(resource: .gray80)
        case .gray85: return UIColor(resource: .gray85)
        case .gray90: return UIColor(resource: .gray90)
        case .primaryGreen: return UIColor(resource: .primaryGreen)
        }
    }
}
