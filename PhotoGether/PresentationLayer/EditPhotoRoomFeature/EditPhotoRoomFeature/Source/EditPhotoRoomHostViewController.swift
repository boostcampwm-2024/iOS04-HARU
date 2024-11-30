import Combine
import UIKit

import BaseFeature
import DesignSystem
import PhotoGetherData
import PhotoGetherDomain
import PhotoGetherDomainInterface
import SharePhotoFeature

public class EditPhotoRoomHostViewController: BaseViewController, ViewControllerConfigure {
    private let navigationView = UIView()
    private let canvasScrollView = CanvasScrollView()
    private let bottomView = EditPhotoHostBottomView()
    private let bottomSheetViewController: StickerBottomSheetViewController
    
    private let input = PassthroughSubject<EditPhotoRoomHostViewModel.Input, Never>()
    
    private let viewModel: EditPhotoRoomHostViewModel
    
    public init(
        viewModel: EditPhotoRoomHostViewModel,
        bottomSheetViewController: StickerBottomSheetViewController
    ) {
        self.viewModel = viewModel
        self.bottomSheetViewController = bottomSheetViewController
        super.init(nibName: nil, bundle: nil)
        self.bottomSheetViewController.delegate = self
        self.canvasScrollView.canvasScrollViewDelegate = self
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
        input.send(.initialState)
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
        navigationView.backgroundColor = PTGColor.gray70.color
    }
    
    public func bindInput() {
        bottomView.stickerButtonTapped
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.input.send(.stickerButtonDidTap)
            }
            .store(in: &cancellables)
        
        bottomView.frameButtonTapped
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.input.send(.frameButtonDidTap)
            }
            .store(in: &cancellables)
        
        bottomView.nextButtonTapped
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.showNextView()
            }
            .store(in: &cancellables)
    }
    
    private func showNextView() {
        guard let imageData = renderCanvasImageView() else { return }
        let component = SharePhotoComponent(imageData: imageData)
        let viewModel = SharePhotoViewModel(component: component)
        let viewController = SharePhotoViewController(viewModel: viewModel)
        
        self.present(viewController, animated: true)
    }
    
    private func renderCanvasImageView() -> Data? {
        return canvasScrollView.makeSharePhoto()
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                switch event {
                case .stickerList(let stickerList):
                    self?.updateCanvas(with: stickerList)
                case .frameImage(let image):
                    self?.updateFrameImage(to: image)
                case .presentStickerBottomSheet:
                    self?.presentStickerBottomSheet()
                }
            }
            .store(in: &cancellables)
    }

    private func updateFrameImage(to image: UIImage) {
        canvasScrollView.updateFrameImage(to: image)
    }
    
    private func updateCanvas(with stickerList: [StickerEntity]) {
        canvasScrollView.updateCanvas(stickerList: stickerList, user: viewModel.owner)
    }
    
    private func createStickerEntity(by entity: EmojiEntity) {
        let imageSize: CGFloat = 64
        let frame = calculateCenterPosition(imageSize: imageSize)
        
        let newSticker = StickerEntity(
            image: entity.image,
            frame: frame,
            owner: nil,
            latestUpdated: Date()
        )
        
        canvasScrollView.addStickerView(with: newSticker, user: viewModel.owner)
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
    
    private func presentStickerBottomSheet() {
        self.present(bottomSheetViewController, animated: true)
    }
}

extension EditPhotoRoomHostViewController: StickerBottomSheetViewControllerDelegate {
    func stickerBottomSheetViewController(
        _ viewController: StickerBottomSheetViewController,
        didTap emoji: EmojiEntity
    ) {
        self.createStickerEntity(by: emoji)
    }
}

extension EditPhotoRoomHostViewController: StickerViewActionDelegate {
    func stickerView(_ stickerView: StickerView, willBeginDraging sticker: PhotoGetherDomainInterface.StickerEntity) {
         
    }
    
    func stickerView(_ stickerView: StickerView, didDrag sticker: PhotoGetherDomainInterface.StickerEntity) {
         
    }
    
    func stickerView(_ stickerView: StickerView, didEndDrag sticker: PhotoGetherDomainInterface.StickerEntity) {
         
    }
    
    func stickerView(_ stickerView: StickerView, didTap id: UUID) {
        input.send(.stickerViewDidTap(id))
    }
    
    func stickerView(_ stickerView: StickerView, didTapDelete id: UUID) {
        input.send(.deleteSticker(id))
    }
}

extension EditPhotoRoomHostViewController: CanvasScrollViewDelegate {
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didTap id: UUID) {
        input.send(.stickerViewDidTap(id))
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didTapDelete id: UUID) {
        input.send(.deleteSticker(id))
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didAdd sticker: StickerEntity) {
        input.send(.createSticker(sticker))
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didBeginDrag sticker: StickerEntity) {
         
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didChangeDrag sticker: StickerEntity) {
         
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didEndDrag sticker: StickerEntity) {
         
    }
}
