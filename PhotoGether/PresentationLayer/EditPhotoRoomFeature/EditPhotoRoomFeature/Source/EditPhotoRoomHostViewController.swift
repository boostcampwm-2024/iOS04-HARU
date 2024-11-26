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
    private var stickerIdDictionary: [UUID: Int] = [:]
    
    public init(
        viewModel: EditPhotoRoomHostViewModel,
        bottomSheetViewController: StickerBottomSheetViewController
    ) {
        self.viewModel = viewModel
        self.bottomSheetViewController = bottomSheetViewController
        super.init(nibName: nil, bundle: nil)
        self.bottomSheetViewController.delegate = self
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
        view.backgroundColor = .brown
        
        navigationView.backgroundColor = .yellow
        bottomView.backgroundColor = .yellow
        canvasScrollView.backgroundColor = .red
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
        guard let imageData = renderCanvasImageView().pngData() else { return }
        let component = SharePhotoComponent(imageData: imageData)
        let viewModel = SharePhotoViewModel(component: component)
        let viewController = SharePhotoViewController(viewModel: viewModel)
        
//        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
    
    private func renderCanvasImageView() -> UIImage {
        canvasScrollView.imageView.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(size: canvasScrollView.imageView.bounds.size)
        let capturedImage = renderer.image { context in
            canvasScrollView.imageView.layer.render(in: context.cgContext)
        }
        return capturedImage
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                switch event {
                case .stickerObjectList(let stickerList):
                    self?.updateCanvas(with: stickerList)
                case .frameImage(let image):
                    self?.updateFrameImage(to: image)
                case .presentStickerBottomSheet:
                    self?.presentStickerBottomSheet()
                }
            }
            .store(in: &cancellables)
        
        viewModel.setupFrame()
    }

    private func updateFrameImage(to image: UIImage) {
        canvasScrollView.updateFrameImage(to: image)
    }
    
    /// DataSource를 기반으로 이미 존재하는 스티커를 업데이트하거나 새로운 스티커를 추가합니다.
    private func updateCanvas(with stickerList: [StickerEntity]) {
        stickerList.forEach { sticker in
            if let targetIndex = stickerIdDictionary[sticker.id] {
                updateExistingSticker(at: targetIndex, with: sticker)
            } else {
                addNewSticker(to: sticker, isLocal: false)
            }
        }
    }
    
    private func updateExistingSticker(
        at index: Int,
        with sticker: StickerEntity
    ) {
        guard let stickerImageView = canvasScrollView
            .imageView
            .subviews[index] as? StickerView
        else { return }
        
        stickerImageView.update(with: sticker)
    }
    
    private func addNewSticker(to sticker: StickerEntity, isLocal: Bool) {
        registerSticker(for: sticker)
        
        let stickerView = StickerView(sticker: sticker)
        stickerView.delegate = self
        
        canvasScrollView.imageView.addSubview(stickerView)
        stickerView.update(with: sticker)
        input.send(.createSticker(sticker))
    }
    
    private func createStickerObject(by entity: EmojiEntity) {
        let imageSize: CGFloat = 64
        let frame = calculateCenterPosition(imageSize: imageSize)
        
        let newStickerObject = StickerEntity(
            image: entity.image,
            frame: frame,
            owner: nil,
            latestUpdated: Date()
        )
        
        addNewSticker(to: newStickerObject, isLocal: true)
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
    
    private func registerSticker(for sticker: StickerEntity) {
        let newIndex = canvasScrollView.imageView.subviews.count
        stickerIdDictionary[sticker.id] = newIndex
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
        self.createStickerObject(by: emoji)
    }
}

extension EditPhotoRoomHostViewController: StickerViewActionDelegate {
    func stickerView(_ stickerView: StickerView, didTap id: UUID) {
        input.send(.stickerViewDidTap(id))
    }
}
