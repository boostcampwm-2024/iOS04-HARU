import UIKit
import BaseFeature
import Combine

public class PhotoRoomViewController: BaseViewController, ViewControllerConfigure {
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
    
    public func addViews() { }
    
    public func setupConstraints() { }
    
    public func configureUI() { }
    
}
