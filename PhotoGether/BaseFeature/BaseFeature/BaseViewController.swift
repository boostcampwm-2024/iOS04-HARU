import UIKit
import Combine

open class BaseViewController: UIViewController {
    public var cancellables = Set<AnyCancellable>()
    let customNavigationBar = UIView()
    
    open func addViews() { }
    open func setupConstraints() { }
    open func configureUI() { }
    open func bindOutput() { }
}
