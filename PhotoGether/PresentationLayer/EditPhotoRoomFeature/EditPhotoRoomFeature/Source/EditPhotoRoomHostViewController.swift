import UIKit
import BaseFeature

public class EditPhotoRoomHostViewController: BaseViewController, ViewControllerConfigure, UIScrollViewDelegate {
    private var viewModel = EditPhotoRoomHostViewModel()
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
        bindInput()
        bindOutput()
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
    
    public func configureUI() { }
    
    public func bindInput() {
        let input = EditPhotoRoomHostViewModel.Input(
            didStickerButtonTapped: bottomView.stickerButtonTapped
        )
        
        viewModel.bind(input: input)
    }
    
    public func bindOutput() {
        let output = viewModel.bindOutput()
        
        output.rectangle
            .sink { [weak self] in
                guard let self else { return }
                let rectangle = UIView(
                    frame: CGRect(
                        origin: $0.position,
                        size: $0.size
                    )
                )
                rectangle.backgroundColor = .cyan
                
                canvasScrollView.imageView.addSubview(rectangle)
            }
            .store(in: &cancellables)
    }
    
    func temp() {
        view.backgroundColor = .brown
        
        navigationView.backgroundColor = .yellow
        bottomView.backgroundColor = .yellow
        canvasScrollView.backgroundColor = .red
    }
}
