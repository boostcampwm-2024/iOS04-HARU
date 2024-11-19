import UIKit
import Combine
import BaseFeature
import DesignSystem
import PhotoGetherDomainInterface

public final class WaitingRoomViewController: BaseViewController, ViewControllerConfigure {
    private let viewModel: WaitingRoomViewModel
    private let waitingRoomView = WaitingRoomView()
    
    public init(viewModel: WaitingRoomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = waitingRoomView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        setupConstraints()
        configureUI()
        setActions()
    }
    
    public func addViews() {
        
    }
    
    public func setupConstraints() {
        
    }
    
    public func configureUI() {
    }
    
    private func setActions() {
    }
}
