import Combine
import UIKit

import BaseFeature
import DesignSystem
import PhotoGetherData
import PhotoGetherDomain
import PhotoGetherDomainInterface
import SharePhotoFeature

public class EditPhotoRoomGuestViewController: BaseViewController, ViewControllerConfigure {
    private let navigationView = UIView()
    private let canvasScrollView = CanvasScrollView()
    private let micButton = PTGMicButton(micState: .on)
    private let bottomView = EditPhotoGuestBottomView()
    private let bottomSheetViewController: StickerBottomSheetViewController
    
    private let input = PassthroughSubject<EditPhotoRoomGuestViewModel.Input, Never>()
    
    private let viewModel: EditPhotoRoomGuestViewModel
    
    public init(
        viewModel: EditPhotoRoomGuestViewModel,
        bottomSheetViewController: StickerBottomSheetViewController
    ) {
        self.viewModel = viewModel
        self.bottomSheetViewController = bottomSheetViewController
        super.init(nibName: nil, bundle: nil)
        self.bottomSheetViewController.delegate = self
        self.canvasScrollView.canvasScrollViewDelegate = self
    }
    
    @available(*, unavailable)
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
        bindNoti()
        micButton.toggleMicState(
            viewModel.fetchLocalVoiceInputState()
        )
        input.send(.initialState)
    }
    
    private func bindNoti() {
        NotificationCenter.default.publisher(for: .receiveNavigateToShareRoom)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.showNextView()
            }.store(in: &cancellables)
    }
    
    public func addViews() {
        [navigationView, canvasScrollView, bottomView, micButton].forEach {
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
        
        micButton.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top).offset(-4)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(52)
        }
    }
    
    public func configureUI() {
        view.backgroundColor = PTGColor.gray90.color
        navigationView.backgroundColor = PTGColor.gray70.color
        navigationView.isHidden = true
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
        
        micButton.tapPublisher
            .sink { [weak self] in
                self?.input.send(.micButtonDidTap)
            }
            .store(in: &cancellables)
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
            case .voiceInputState(let isOn):
                self?.micButton.toggleMicState(isOn)
            }
        }
        .store(in: &cancellables)
    }
    
    private func showNextView() {
        guard let imageData = renderCanvasImageView() else { return }
        let component = SharePhotoComponent(imageData: imageData)
        let viewModel = SharePhotoViewModel(component: component)
        let viewController = SharePhotoViewController(viewModel: viewModel)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func renderCanvasImageView() -> Data? {
        return canvasScrollView.makeSharePhoto()
    }
    
    private func updateFrameImage(to image: UIImage) {
        canvasScrollView.updateFrameImage(to: image)
    }
    
    private func updateCanvas(with stickerList: [StickerEntity]) {
        canvasScrollView.updateCanvas(stickerList: stickerList, user: viewModel.userInfo)
    }
    
    private func createStickerEntity(by entity: EmojiEntity) {
        let imageSize: CGFloat = 72
        let frame = calculateCenterPosition(imageSize: imageSize)
        guard let emojiURL = entity.emojiURL else { return }
        
        let newSticker = StickerEntity(
            image: emojiURL.absoluteString,
            frame: frame,
            owner: nil,
            latestUpdated: Date()
        )
        
        canvasScrollView.addStickerView(with: newSticker, user: viewModel.userInfo)
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
    
    public func inject(_ frameImageGenerator: FrameImageGenerator, userInfo: UserInfo?) {
        guard let userInfo else { return }
        viewModel.setViewModel(frameImageGenerator, userInfo: userInfo)
    }
}

extension EditPhotoRoomGuestViewController: StickerBottomSheetViewControllerDelegate {
    func stickerBottomSheetViewController(
        _ viewController: StickerBottomSheetViewController,
        didTap emoji: EmojiEntity
    ) {
        self.createStickerEntity(by: emoji)
    }
}

extension EditPhotoRoomGuestViewController: CanvasScrollViewDelegate {
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
        input.send(.dragSticker(sticker, .began))
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didChangeDrag sticker: StickerEntity) {
        input.send(.dragSticker(sticker, .changed))
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didEndDrag sticker: StickerEntity) {
        input.send(.dragSticker(sticker, .ended))
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didBeginResize sticker: StickerEntity) {
        input.send(.resizeSticker(sticker, .began))
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didChangeResize sticker: StickerEntity) {
        input.send(.resizeSticker(sticker, .changed))
    }
    
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didEndResize sticker: StickerEntity) {
        input.send(.resizeSticker(sticker, .ended))
    }
}
