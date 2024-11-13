import UIKit
import DesignSystem

final class DefaultFrameView: FrameView {
    private let frameImageView: DefaultFrameImageView
    private let label = UILabel()
    private let frameColor: FrameColor
    
    init(images: [UIImage], color: FrameColor) {
        self.frameImageView = DefaultFrameImageView(images: images)
        self.frameColor = color
        super.init()
        addViews()
        setupConstraints()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addViews() {
        addSubview(frameImageView)
        addSubview(label)
    }
    
    override func setupConstraints() {
        frameImageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(477.67)
        }
        
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(48)
        }
    }
    
    override func configureUI() {
        backgroundColor = frameColor.color
        
        label.text = "PhotoGether"
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = PTGColor.primaryGreen.color
    }
}

extension DefaultFrameView {
    enum FrameColor {
        case black, white
        
        var color: UIColor {
            switch self {
            case .black:
                return PTGColor.gray85.color
            case .white:
                return PTGColor.gray10.color
            }
        }
    }
}
