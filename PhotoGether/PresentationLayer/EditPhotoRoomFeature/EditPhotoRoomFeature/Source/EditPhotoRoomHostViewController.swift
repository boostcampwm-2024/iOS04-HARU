import UIKit
import Combine
import BaseFeature

public class EditPhotoRoomHostViewController: BaseViewController, ViewControllerConfigure {
    private let navigationView = UIView()
    private let canvasScrollView = CanvasScrollView()
    private let bottomView = EditPhotoHostBottomView()
    
    private let input = PassthroughSubject<EditPhotoRoomHostViewModel.Input, Never>()
    
    private let viewModel: EditPhotoRoomHostViewModel
    
    public init(viewModel: EditPhotoRoomHostViewModel) {
        self.viewModel = viewModel
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
        bottomView.stickerButtonTapped
            .sink { [weak self] in
                self?.input.send(.stickerButtonDidTap)
            }
            .store(in: &cancellables)
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] in
            switch $0 {
            case .sticker(let data):
                self?.renderSticker(data: data)
            }
        }
        .store(in: &cancellables)
    }
    
    func temp() {
        view.backgroundColor = .brown
        
        navigationView.backgroundColor = .yellow
        bottomView.backgroundColor = .yellow
        canvasScrollView.backgroundColor = .red
    }
    
    private func renderSticker(data: Data) {
        let rect = calculateCenterPosition(imageSize: 60)
        
        let stickerImageView = UIView(frame: rect)
        stickerImageView.backgroundColor = .cyan
        
        canvasScrollView.imageView.addSubview(stickerImageView)
    }
    
    private func calculateCenterPosition(imageSize: CGFloat) -> CGRect {
        let zoomScale = canvasScrollView.zoomScale
        let bounds = canvasScrollView.bounds
        
        let centerX = bounds.midX / zoomScale
        let centerY = bounds.midY / zoomScale
        
        let size = imageSize / sqrt(zoomScale)
        
        return CGRect(
            x: centerX - size / 2,
            y: centerY - size / 2,
            width: size,
            height: size
        )
    }
    
    private func generateRectangle(rect: Rectangle) {
        let view = UIView(
            frame: CGRect(
                origin: rect.position,
                size: rect.size
            )
        )
        
        view.backgroundColor = .white
        canvasScrollView.imageView.addSubview(view)
    }
}
