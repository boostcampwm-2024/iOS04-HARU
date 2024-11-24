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
    
    // MARK: 개발 끝나면 지워야됨
    private let offerUseCase: SendOfferUseCase
    private var isConnected = false
    
    public init(
        viewModel: EditPhotoRoomGuestViewModel,
        offerUseCase: SendOfferUseCase
    ) {
        self.viewModel = viewModel
        self.offerUseCase = offerUseCase
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
            case .frameImage(let image):
                self?.updateFrameImage(to: image)
            }
        }
        .store(in: &cancellables)
        
        viewModel.setupFrame()
    }
    
    private func tempOffer() {
        print("DEBUG: OFFER")
        offerUseCase.execute()
    }
    
    private func updateFrameImage(to image: UIImage) {
        // MARK: 임시 클라연결
        if isConnected { tempOffer() }
        else { canvasScrollView.updateFrameImage(to: image) }
        isConnected = true
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
        guard
            let stickerImageView = canvasScrollView.imageView.subviews[index]
                as? UIImageView
        else { return }
        
        guard let url = URL(string: sticker.image) else { return }
        Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url)
            else { return }
            stickerImageView.image = UIImage(data: data)
            stickerImageView.frame = sticker.frame
        }
    }
    
    private func addNewSticker(to sticker: StickerEntity, isLocal: Bool) {
        registerSticker(for: sticker)
        
        guard let url = URL(string: sticker.image) else { return }
        Task {
            guard let (data, _) = try? await URLSession.shared.data(from: url)
            else { return }
            
            let stickerImageView = UIImageView(frame: sticker.frame)
            stickerImageView.image = await UIImage(data: data)?.byPreparingForDisplay()
            canvasScrollView.imageView.addSubview(stickerImageView)

            if isLocal {
                print("DEBUG: ADD NEW STICKER By Local, \(sticker.id)")
                input.send(.createSticker(sticker))
            } else {
                print("DEBUG: ADD NEW STICKER By Host, \(sticker.id)")
            }
        let stickerView = StickerView(sticker: sticker)
        stickerView.tapHandler { [weak self] stickerID in
            self?.input.send(.stickerViewDidTap(stickerID))
        }
        
    }
    
    // MARK: 원래는 Data가 아니라 imageURL 및 Image의 MetaData가 와야함.
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
}
