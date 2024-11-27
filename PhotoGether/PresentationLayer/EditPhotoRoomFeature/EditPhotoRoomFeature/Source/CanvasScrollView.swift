import UIKit

import DesignSystem
import PhotoGetherDomainInterface

final class CanvasScrollView: UIScrollView {
    let imageView = UIImageView()
    
    private var stickerViewDictonary: [UUID: StickerView]

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
        maximumZoomScale = 3
        bouncesZoom = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        imageView.isUserInteractionEnabled = true
    }
}

// MARK: - StickerView methods
extension CanvasScrollView {
    func findStickerView(with id: UUID) -> StickerView? {
        return stickerViewDictonary[id]
    }
    
    func createStickerView(
        _ target: StickerViewActionDelegate,
        with sticker: StickerEntity,
        user: String
    ) {
        let stickerView = StickerView(sticker: sticker, user: user)
        stickerView.delegate = target
        
        stickerViewDictonary[sticker.id] = stickerView
        imageView.addSubview(stickerView)
        stickerView.update(with: sticker)
    }
    
    func updateStickerView(with sticker: StickerEntity) {
        guard let stickerView = findStickerView(with: sticker.id) else { return }
        stickerView.update(with: sticker)
    }
    
    func deleteStickerView(with id: UUID) {
        guard let stickerView = findStickerView(with: id) else { return }
        stickerView.removeFromSuperview()
        stickerViewDictonary[id] = nil
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
}

// MARK: - Sub method
extension CanvasScrollView {
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
