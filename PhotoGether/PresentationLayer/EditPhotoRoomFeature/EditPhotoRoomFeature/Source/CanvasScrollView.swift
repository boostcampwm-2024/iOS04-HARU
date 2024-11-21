import UIKit
import DesignSystem

final class CanvasScrollView: UIScrollView {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        delegate = self
        addViews()
        configureUI()
    }
    
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
    }
    
    func updateFrameImage(to image: UIImage) {
        imageView.image = image
        imageView.sizeToFit()
    }
    
    func contentCentering() {
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
    
    func setupZoomScale() {
        guard let image = imageView.image else { return }
        
        let widthBaseScale = frame.width / image.size.width
        let heightBaseScale = frame.height / image.size.height
        let calculatedZoomScale = min(widthBaseScale, heightBaseScale)
        
        zoomScale = calculatedZoomScale
        minimumZoomScale = calculatedZoomScale
    }
}

extension CanvasScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentCentering()
        return imageView
    }
}
