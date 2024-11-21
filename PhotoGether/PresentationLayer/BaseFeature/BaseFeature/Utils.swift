import UIKit

public func APP_HEIGHT() -> CGFloat {
    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    return windowScene?.screen.bounds.size.height ?? .zero
}
