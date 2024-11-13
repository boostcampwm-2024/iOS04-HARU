import UIKit
import DesignSystem

final class CanvasScrollView: UIScrollView {
    private let image = PTGImage.sampleImage.image
    let imageView = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        delegate = self
        addViews()
        setupConstraints()
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
    
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.width.equalTo(image.size.width)
            $0.height.equalTo(image.size.height)
        }
    }
    
    private func configureUI() {
        isScrollEnabled = true
        maximumZoomScale = 3
        bouncesZoom = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
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
        let widthBaseScale = frame.width / image.size.width
        let heightBaseScale = frame.height / image.size.height
        let calculatedZoomScale = min(widthBaseScale, heightBaseScale)
        
        zoomScale = calculatedZoomScale
        minimumZoomScale = calculatedZoomScale
    }
}

extension CanvasScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
