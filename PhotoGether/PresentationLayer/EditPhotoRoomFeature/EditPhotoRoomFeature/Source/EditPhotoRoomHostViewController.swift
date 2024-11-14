import BaseFeature
import Combine
import DesignSystem
import PhotoGetherDomainInterface
import SharePhotoFeature
import UIKit

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
//        temp()
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
    
    public func configureUI() {
        view.backgroundColor = PTGColor.gray90.color
        
        navigationView.backgroundColor = .clear
        bottomView.backgroundColor = .clear
        canvasScrollView.backgroundColor = .clear
        canvasScrollView.imageView.image = viewModel.generateFrameImage()
    }
    
    public func bindInput() {
        bottomView.frameButtonTapped
            .sink { [weak self] in
                self?.input.send(.frameButtonDidTap)
            }
            .store(in: &cancellables)
        
        bottomView.stickerButtonTapped
            .sink { [weak self] in
                self?.input.send(.stickerButtonDidTap)
            }
            .store(in: &cancellables)
        
        bottomView.nextButtonTapped
            .sink { [weak self] in
                self?.input.send(.nextButtonDidTap)
            }
            .store(in: &cancellables)
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] in
            switch $0 {
            case .rectangle(let rect):
                self?.generateRectangle(rect: rect)
            case .frameImage(let image):
                self?.canvasScrollView.imageView.image = image
            case .showSharePhoto:
                self?.showSharePhoto()
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
    
    private func showSharePhoto() {
        guard let imageData = captureCanvasScrollImageView().pngData() else { return }
        let component = SharePhotoComponent(imageData: imageData)
        let viewModel = SharePhotoViewModel(component: component)
        let viewController = SharePhotoViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func captureCanvasScrollImageView() -> UIImage {
        let imageView = canvasScrollView.imageView
        let renderer = UIGraphicsImageRenderer(size: imageView.frame.size)
        let capturedImage = renderer.image { context in
            imageView.layer.render(in: context.cgContext)
        }
        return capturedImage
    }
}
