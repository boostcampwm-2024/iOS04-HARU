import UIKit

final class DefaultBlackFrameImageView: FrameImageView {
    override init(images: [UIImage]) {
        super.init(images: images)
        setupConstraints()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        let positions = LayoutPosition.forParticipant(participants).values
        
        for (index, imageView) in imageViews.enumerated() {
            let position = positions[index]
            imageView.snp.makeConstraints {
                $0.width.equalTo(FrameConstants.imageSize.width)
                $0.height.equalTo(FrameConstants.imageSize.height)

                if position.top {
                    $0.top.equalToSuperview()
                } else {
                    $0.bottom.equalToSuperview()
                }
                
                if position.leading {
                    $0.leading.equalToSuperview()
                } else {
                    $0.trailing.equalToSuperview()
                }
            }
        }
    }
    
    override func configureUI() {
        super.configureUI()
        
        for (index, image) in images.enumerated() {
            if index < imageViews.count {
                imageViews[index].image = image
            }
        }
    }
}

private extension DefaultBlackFrameImageView {
    enum LayoutPosition {
        case single, pair, trio, quad
        
        var values: [AnchorPosition] {
            switch self {
            case .single:
                return [
                    .topLeading
                ]
            case .pair:
                return [
                    .topLeading,
                    .bottomTrailing
                ]
            case .trio:
                return [
                    .topLeading,
                    .topTrailing,
                    .bottomLeading
                ]
            case .quad:
                return [
                    .topLeading,
                    .topTrailing,
                    .bottomLeading,
                    .bottomTrailing
                ]
            }
        }
        
        static func forParticipant(_ participant: Participant) -> LayoutPosition {
            switch participant {
            case .single:
                return .single
            case .pair:
                return .pair
            case .trio:
                return .trio
            case .quad:
                return .quad
            }
        }
    }
    
    struct AnchorPosition {
        let top: Bool
        let leading: Bool
        
        static let topLeading = AnchorPosition(top: true, leading: true)
        static let topTrailing = AnchorPosition(top: true, leading: false)
        static let bottomLeading = AnchorPosition(top: false, leading: true)
        static let bottomTrailing = AnchorPosition(top: false, leading: false)
    }
}
