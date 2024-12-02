import UIKit

import DesignSystem
import PhotoGetherDomainInterface

protocol CanvasScrollViewDelegate: AnyObject {
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didTap id: UUID)
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didTapDelete id: UUID)
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didAdd sticker: StickerEntity)
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didBeginDrag sticker: StickerEntity)
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didChangeDrag sticker: StickerEntity)
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didEndDrag sticker: StickerEntity)
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didBeginResize sticker: StickerEntity)
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didChangeResize sticker: StickerEntity)
    func canvasScrollView(_ canvasScrollView: CanvasScrollView, didEndResize sticker: StickerEntity)
}

final class CanvasScrollView: UIScrollView {
    private let imageView = UIImageView()
    private var stickerViewDictonary: [UUID: StickerView]

    weak var canvasScrollViewDelegate: CanvasScrollViewDelegate?
    
    override init(frame: CGRect) {
        self.stickerViewDictonary = [:]
        super.init(frame: frame)
        
        delegate = self
        addViews()
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        [imageView].forEach {
            addSubview($0)
        }
    }
    
    private func configureUI() {
        isScrollEnabled = true
        maximumZoomScale = 2
        bouncesZoom = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        backgroundColor = PTGColor.gray90.color
        
        imageView.isUserInteractionEnabled = true
    }
}

// MARK: - StickerView methods
extension CanvasScrollView {
    func updateCanvas(
        stickerList: [StickerEntity],
        user: UserInfo
    ) {
        prepareForApply(stickerList)
        applyStickerList(for: stickerList, user: user)
    }
    
    func addStickerView(
        with sticker: StickerEntity,
        user: UserInfo
    ) {
        let stickerView = StickerView(sticker: sticker, user: user)
        stickerView.delegate = self
        
        stickerViewDictonary[sticker.id] = stickerView
        imageView.addSubview(stickerView)
        stickerView.update(with: sticker)
        
        canvasScrollViewDelegate?.canvasScrollView(self, didAdd: sticker)
    }
    
    private func updateStickerView(with sticker: StickerEntity) {
        guard let stickerView = findStickerView(with: sticker.id) else { return }
        stickerView.update(with: sticker)
    }
    
    private func deleteStickerView(with id: UUID) {
        guard let stickerView = findStickerView(with: id) else { return }
        stickerView.removeFromSuperview()
        stickerViewDictonary[id] = nil
    }
    
    private func prepareForApply(_ stickerList: [StickerEntity]) {
        let stickerIdList = stickerViewDictonary.keys.map { $0 }
        
        Set(stickerIdList)
            .subtracting(stickerList.map { $0.id })
            .forEach { deleteStickerView(with: $0) }
    }
    
    private func applyStickerList(
        for stickerList: [StickerEntity],
        user: UserInfo
    ) {
        stickerList.forEach { sticker in
            switch isExistStickerView(with: sticker.id) {
            case true:
                updateStickerView(with: sticker)
            case false:
                addStickerView(with: sticker, user: user)
            }
        }
    }
}

// MARK: - ImageView setup methods
extension CanvasScrollView {
    func updateFrameImage(to image: UIImage) {
        imageView.image = image
        
        self.imageView.sizeToFit()
        self.setupZoomScale()
        self.contentCentering()
    }
    
    func makeSharePhoto() -> Data? {
        imageView.layoutIfNeeded()
        stickerViewDictonary.values.forEach { $0.prepareSharePhoto() }
        let renderer = UIGraphicsImageRenderer(size: imageView.bounds.size)
        let capturedImage = renderer.image { context in
            imageView.layer.render(in: context.cgContext)
        }
        stickerViewDictonary.values.forEach { $0.finishSharePhoto() }
        return capturedImage.pngData()
    }
}

// MARK: - Sub method
extension CanvasScrollView {
    private func findStickerView(with id: UUID) -> StickerView? {
        return stickerViewDictonary[id]
    }
    
    private func isExistStickerView(with id: UUID) -> Bool {
        return stickerViewDictonary.keys.contains(id)
    }
    
    private func contentCentering() {
        let scrollView = self
        let contentView = imageView

        let scrollViewSize = scrollView.bounds.size
        let contentSize = contentView.frame.size

        let horizontalInset = max((scrollViewSize.width - contentSize.width) / 2, 0)
        let verticalInset = max((scrollViewSize.height - contentSize.height) / 2, 0)

        contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    private func setupZoomScale() {
        guard let image = imageView.image else { return }
        
        let widthBaseScale = frame.width / image.size.width
        let heightBaseScale = frame.height / image.size.height
        let calculatedZoomScale = min(widthBaseScale, heightBaseScale)
        
        // 호출 순서 바꾸면 안됨
        minimumZoomScale = calculatedZoomScale
        zoomScale = calculatedZoomScale
    }
}

extension CanvasScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension CanvasScrollView: StickerViewActionDelegate {
    func stickerView(_ stickerView: StickerView, didTap id: UUID) {
        canvasScrollViewDelegate?.canvasScrollView(self, didTap: id)
    }
    
    func stickerView(_ stickerView: StickerView, didTapDelete id: UUID) {
        canvasScrollViewDelegate?.canvasScrollView(self, didTapDelete: id)
    }
    
    func stickerView(_ stickerView: StickerView, willBeginDraging sticker: StickerEntity) {
        canvasScrollViewDelegate?.canvasScrollView(self, didBeginDrag: sticker)
    }
    
    func stickerView(_ stickerView: StickerView, didDrag sticker: StickerEntity) {
        canvasScrollViewDelegate?.canvasScrollView(self, didChangeDrag: sticker)
    }
    
    func stickerView(_ stickerView: StickerView, didEndDrag sticker: StickerEntity) {
        canvasScrollViewDelegate?.canvasScrollView(self, didEndDrag: sticker)
    }
    
    func stickerView(_ stickerView: StickerView, willBeginResizing sticker: StickerEntity) {
        canvasScrollViewDelegate?.canvasScrollView(self, didBeginResize: sticker)
    }
    
    func stickerView(_ stickerView: StickerView, didResize sticker: StickerEntity) {
        canvasScrollViewDelegate?.canvasScrollView(self, didChangeResize: sticker)
    }
    
    func stickerView(_ stickerView: StickerView, didEndResize sticker: StickerEntity) {
        canvasScrollViewDelegate?.canvasScrollView(self, didEndResize: sticker)
    }
}
