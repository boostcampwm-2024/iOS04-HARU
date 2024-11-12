import UIKit
import BaseFeature

public class EditPhotoRoomHostViewController: BaseViewController {
    private let bottomView = EditPhotoHostBottomView()
    private let navigationView = UIView()
    private let canvasView = UIScrollView()
    private let contentView = UIView()
    
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
        // configureUI()
        temp()
    }
    
    public override func addViews() {
        [navigationView, canvasView, bottomView].forEach {
            view.addSubview($0)
        }
        
        canvasView.addSubview(contentView)
    }
    
    public override func setupConstraints() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        canvasView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(1000)
            $0.height.equalTo(1000)
            $0.center.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(80)
        }
    }
    
    // TODO: 디자인 시스템에 컬러 에셋 추가 후 구현 예정
    public override func configureUI() {
        
    }
    
    func temp() {
        view.backgroundColor = .brown
        
        navigationView.backgroundColor = .yellow
        bottomView.backgroundColor = .yellow
        
        canvasView.backgroundColor = .red
        contentView.backgroundColor = .blue
    }
}
