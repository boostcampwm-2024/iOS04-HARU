import UIKit
import BaseFeature
import Combine
import DesignSystem

public class PhotoRoomViewController: BaseViewController, ViewControllerConfigure {
    let photoHostBottomView = PhotoRoomBottomView(isHost: false)
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        addViews()
        setupConstraints()
        configureUI()
    }
    
    public func addViews() {
        view.addSubview(photoHostBottomView)
    }
    
    public func setupConstraints() {
        photoHostBottomView.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(68)
        }
    }
    
    public func configureUI() { }
}
