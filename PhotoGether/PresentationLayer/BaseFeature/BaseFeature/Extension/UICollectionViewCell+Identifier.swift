import UIKit

public extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
