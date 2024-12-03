import UIKit
import SnapKit

public final class PTGGrayButton: UIButton {
    private let type: PTGGrayButtonType
    private let stackView = UIStackView()
    private let grayButtonImage = UIImageView()
    private let grayButtonLabel = UILabel()

    public init(type: PTGGrayButtonType) {
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
        addSubview(stackView)
        [grayButtonImage, grayButtonLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setupConstraints() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        grayButtonImage.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
    }
    
    private func configureUI() {
        backgroundColor = .gray85
        layer.cornerRadius = 12
        isExclusiveTouch = true
        
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.isUserInteractionEnabled = false
        
        grayButtonImage.image = type.image
        grayButtonImage.contentMode = .scaleAspectFit
        grayButtonImage.tintColor = .white
        
        grayButtonLabel.text = type.text
        grayButtonLabel.textColor = .white
        grayButtonLabel.font = .systemFont(ofSize: 16, weight: .semibold)
    }
}

public extension PTGGrayButton {
    enum PTGGrayButtonType {
        case frame
        case sticker
        
        var text: String {
            switch self {
            case .frame:
                return "프레임"
            case .sticker:
                return "스티커"
            }
        }
        
        var image: UIImage {
            switch self {
            case .frame:
                return PTGImage.frameIcon.image
            case .sticker:
                return PTGImage.stickerIcon.image
            }
        }
    }
}
