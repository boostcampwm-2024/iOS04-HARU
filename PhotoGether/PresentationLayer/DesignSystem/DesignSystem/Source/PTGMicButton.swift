import UIKit
import SnapKit

public final class PTGMicButton: UIButton {
    private let buttonImage = UIImageView()
    private var micState: PTGMicState
    
    public init(micState: PTGMicState) {
        self.micState = micState
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
        backgroundColor = .white.withAlphaComponent(0.2)
        
        buttonImage.contentMode = .scaleAspectFit
        buttonImage.image = UIImage(systemName: micState.image)
        buttonImage.tintColor = micState.color
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
    
    public func toggleMicState(_ isOn: Bool) {
        micState = isOn ? .on : .off
        
        buttonImage.image = UIImage(systemName: micState.image)
        buttonImage.tintColor = micState.color
    }
}

public extension PTGMicButton {
    enum PTGMicState {
        case on
        case off
        
        var image: String {
            switch self {
            case .on: 
                return "microphone"
            case .off: 
                return "microphone.slash"
            }
        }
        
        var color: UIColor {
            switch self {
            case .on:
                return .white
            case .off:
                return .red
            }
        }
    }
}
