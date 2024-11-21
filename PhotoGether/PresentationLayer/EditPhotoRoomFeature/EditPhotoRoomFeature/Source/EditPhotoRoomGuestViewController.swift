import UIKit
import PhotoGetherDomainInterface
import Combine
import BaseFeature
import DesignSystem

public class EditPhotoRoomGuestViewController: BaseViewController, ViewControllerConfigure {
    private let navigationView = UIView()
    private let canvasScrollView = CanvasScrollView()
    private let bottomView = EditPhotoGuestBottomView()
    
    private let input = PassthroughSubject<EditPhotoRoomGuestViewModel.Input, Never>()
    
    private let viewModel: EditPhotoRoomGuestViewModel
    private var stickerIdDictionary: [UUID: Int] = [:]
    
    public init(viewModel: EditPhotoRoomGuestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        view.backgroundColor = .brown
        
        navigationView.backgroundColor = .yellow
        bottomView.backgroundColor = .yellow
        canvasScrollView.backgroundColor = .red
        
        canvasScrollView.imageView.sizeToFit()
    }
    
    public func bindInput() {
        bottomView.stickerButtonTapped
            .sink { [weak self] in
                self?.input.send(.stickerButtonDidTap)
            }
            .store(in: &cancellables)
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
            switch event {
            case .emojiEntity(let emojiEntity):
                self?.createStickerObject(by: emojiEntity)
            case .stickerObjectList(let stickerList):
                self?.updateCanvas(with: stickerList)
            }
        }
        .store(in: &cancellables)
    }
    
    /// DataSource를 기반으로 이미 존재하는 스티커를 업데이트하거나 새로운 스티커를 추가합니다.
    private func updateCanvas(with stickerList: [StickerObject]) {
        stickerList.forEach { sticker in
            if let targetIndex = stickerIdDictionary[sticker.id] {
                updateExistingSticker(at: targetIndex, with: sticker)
            } else {
                addNewSticker(to: sticker)
            }
        }
    }
    
    private func updateExistingSticker(
        at index: Int,
        with sticker: StickerObject
    ) {
        guard
            let stickerImageView = canvasScrollView.imageView.subviews[index]
                as? UIImageView
        else { return }
        
        stickerImageView.image = UIImage(data: sticker.image)
        stickerImageView.frame = sticker.rect
    }
    
    private func addNewSticker(to sticker: StickerObject) {
        registerSticker(for: sticker)
        
        let stickerImageView = UIImageView(frame: sticker.rect)
        stickerImageView.image = UIImage(data: sticker.image)
        canvasScrollView.imageView.addSubview(stickerImageView)
    }
    
    // MARK: 원래는 Data가 아니라 imageURL 및 Image의 MetaData가 와야함.
    private func createStickerObject(by entity: EmojiEntity) {
        let imageSize: CGFloat = 64
        let rect = calculateCenterPosition(imageSize: imageSize)
        
        guard let url = URL(string: entity.image) else { return }
        Task {
            guard let (data, response) = try? await URLSession.shared.data(from: url)
            else { return }
            
            let newStickerObject = StickerObject(
                id: UUID(),
                image: data,
                rect: rect
            )
            input.send(.stickerObjectData(newStickerObject))
        }
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
    
    private func registerSticker(for sticker: StickerObject) {
        let newIndex = canvasScrollView.imageView.subviews.count
        stickerIdDictionary[sticker.id] = newIndex
    }
}
