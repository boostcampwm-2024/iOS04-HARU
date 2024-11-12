import UIKit
import SnapKit

public final class PTGCircleButton: UIButton {
    private let type: PTGCircleButtonType
    private let buttonImage = UIImageView()

    public init(type: PTGCircleButtonType) {
        self.type = type
        super.init(frame: .zero)
        
        addViews()
        setupConstraints()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        addSubview(buttonImage)
    }
    
    private func setupConstraints() {
        buttonImage.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.center.equalToSuperview()
        }
    }
    
    private func configureUI() {
        backgroundColor = .white
        buttonImage.image = UIImage(systemName: type.image)
        buttonImage.contentMode = .scaleAspectFit
        buttonImage.tintColor = .gray90
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}

public extension PTGCircleButton {
    enum PTGCircleButtonType {
        case link
        case share
        
        var image: String {
            switch self {
            case .link:
                return "link"
            case .share:
                return "square.and.arrow.up"
            }
        }
    }
}
