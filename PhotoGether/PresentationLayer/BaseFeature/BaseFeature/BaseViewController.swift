import UIKit
import Combine

open class BaseViewController: UIViewController {
    public var cancellables = Set<AnyCancellable>()
    let customNavigationBar = UIView()
    
    open override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension BaseViewController {
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
