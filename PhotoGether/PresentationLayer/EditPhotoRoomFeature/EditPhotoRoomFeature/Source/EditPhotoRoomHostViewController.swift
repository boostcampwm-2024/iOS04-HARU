import UIKit
import BaseFeature

public class EditPhotoRoomHostViewController: BaseViewController, ViewControllerConfigure, UIScrollViewDelegate {
    private let navigationView = UIView()
    private let canvasScrollView = CanvasScrollView()
    private let bottomView = EditPhotoHostBottomView()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        setupConstraints()
        configureUI()
        temp()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        canvasScrollView.setupZoomScale()
        canvasScrollView.contentCentering()
    }
    
    public func addViews() {
        [navigationView, canvasScrollView, bottomView].forEach {
            view.addSubview($0)
        }
    }
    
    public func setupConstraints() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        canvasScrollView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(80)
        }
    }
    
    // TODO: 디자인 시스템에 컬러 에셋 추가 후 구현 예정
    public func configureUI() {
        
    }
    
    func temp() {
        view.backgroundColor = .brown
        
        navigationView.backgroundColor = .yellow
        bottomView.backgroundColor = .yellow
        canvasScrollView.backgroundColor = .red
    }
}
