import UIKit
import DesignSystem

final class CameraButton: UIButton {
    private let innerCircle = UIView()
    private let innerEllipsis = UIImageView()
    private let isHost: Bool
    
    // MARK: init
    init(isHost: Bool) {
        self.isHost = isHost
        super.init(frame: .zero)
        
        addViews()
        setupContstraints()
        configureUI()
        
        guard isHost else { return }
        setActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        [innerCircle, innerEllipsis].forEach { addSubview($0) }
    }
    
    private func setupContstraints() {
        innerCircle.snp.makeConstraints {
            $0.width.height.equalTo(Constants.innerCircleSize)
            $0.center.equalToSuperview()
        }
        
        innerEllipsis.snp.makeConstraints {
            $0.width.equalTo(Constants.ellipsisWidth)
            $0.height.equalTo(Constants.ellipsisHeight)
            $0.center.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.backgroundColor = .clear
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = Constants.ringWidth
        
        innerCircle.isUserInteractionEnabled = false
        innerCircle.backgroundColor = isHost ? .white : PTGColor.gray85.color
        
        innerEllipsis.isHidden = isHost
        innerEllipsis.image = PTGImage.ellipsisIcon.image
    }
    
    // MARK: 터치 시 카메라 버튼 색상 변경
    private func setActions() {
        self.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.innerCircle.backgroundColor = PTGColor.gray85.color
        }, for: .touchDown)
        
        self.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.innerCircle.backgroundColor = .white
        }, for: [.touchCancel, .touchUpOutside])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width / 2
        
        innerCircle.layer.cornerRadius = innerCircle.bounds.width / 2
    }
}

extension CameraButton {
    enum Constants {
        fileprivate static let ringWidth: CGFloat = 4
        fileprivate static let innerCircleSize: CGFloat = 52
        fileprivate static let ellipsisWidth: CGFloat = 34
        fileprivate static let ellipsisHeight: CGFloat = 6
        
        static let buttonSize: CGFloat = 64
    }
}
