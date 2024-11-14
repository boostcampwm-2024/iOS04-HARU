import UIKit

public protocol FrameImageGenerator {
    func generate() -> UIImage
    func changeFrame(to type: FrameType)
    
    var frameType: FrameType { get }
    var images: [UIImage] { get }
}

public final class FrameImageGeneratorImpl: FrameImageGenerator {
    public private(set) var images: [UIImage]
    public private(set) var frameType: FrameType = .defaultBlack {
        didSet {
            frameView = makeFrameView()
        }
    }
    private var frameView: FrameViewRenderable!
    
    public init(images: [UIImage]) {
        self.images = images
        self.frameView = makeFrameView()
    }
    
    // MARK: 전략 패턴으로 프레임 추가 구성 (ex. DefaultWhiteFrameView)
    private func makeFrameView() -> FrameViewRenderable {
        switch frameType {
        case .defaultBlack:
            return DefaultFrameView(images: images, color: .black)
        case .defaultWhite:
            return DefaultFrameView(images: images, color: .white)
        }
    }
    
    public func changeFrame(to type: FrameType) {
        self.frameType = type
    }
    
    public func generate() -> UIImage {
        return frameView.render()
    }
}

public enum FrameType {
    case defaultBlack
    case defaultWhite
}
