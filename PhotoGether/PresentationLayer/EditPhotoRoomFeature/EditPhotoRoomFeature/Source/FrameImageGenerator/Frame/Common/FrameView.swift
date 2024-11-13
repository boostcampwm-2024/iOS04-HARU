import UIKit

class FrameView: UIView {
    init() {
        super.init(
            frame: CGRect(
                origin: .zero,
                size: FrameConstants.frameViewSize
            )
        )
    }
    
    func addViews() { }
    
    func setupConstraints() { }
    
    func configureUI() { }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FrameView: FrameViewRenderable {
    func render() -> UIImage {
        layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(size: FrameConstants.frameViewSize)
        let capturedImage = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        return capturedImage
    }
}
