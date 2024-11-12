import UIKit

public extension UIImage {
    static func load(name: String) -> UIImage? {
        let image = UIImage(
            named: name,
            in: Bundle.init(identifier: "kr.codesquad.boostcamp9.DesignSystem"),
            compatibleWith: nil
        )
        return image
    }
}
