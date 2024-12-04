import UIKit

public extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hexString).scanHexInt64(&int)
        
        let red, green, blue, alpha: UInt64
        switch hexString.count {
        case 6: // 6자리 (RGB)
            (red, green, blue, alpha) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, 0xFF)
        case 8: // 8자리 (RGBA)
            (red, green, blue, alpha) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (red, green, blue, alpha) = (0, 0, 0, 0xFF) // 유효하지 않은 경우 기본값
        }
        
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha) / 255.0
        )
    }
}
