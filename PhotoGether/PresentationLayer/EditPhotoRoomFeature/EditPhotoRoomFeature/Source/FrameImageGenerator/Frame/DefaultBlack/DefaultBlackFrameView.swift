import UIKit
import DesignSystem

final class DefaultBlackFrameView: FrameView {
    private let frameImageView: DefaultBlackFrameImageView
    private let label = UILabel()
    
    init(images: [UIImage]) {
        self.frameImageView = DefaultBlackFrameImageView(images: images)
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
        backgroundColor = PTGColor.gray10.color
        
        label.text = "PhotoGether"
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = PTGColor.primaryGreen.color
    }
}
