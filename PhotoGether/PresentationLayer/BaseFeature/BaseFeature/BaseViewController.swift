import UIKit
import Combine

open class BaseViewController: UIViewController {
    public var cancellables = Set<AnyCancellable>()
    let customNavigationBar = UIView()
}

public protocol ViewControllerConfigure {
    func addViews()
    func setupConstraints()
    func configureUI()
    func bindInput()
    func bindOutput()
}

public extension ViewControllerConfigure {
    func bindInput() { }
    func bindOutput() { }
}
