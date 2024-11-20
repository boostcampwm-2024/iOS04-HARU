import UIKit
import Combine
import DesignSystem

final class EditPhotoGuestBottomView: UIView {
    private let stackView = UIStackView()
    private let frameButton = PTGGrayButton(type: .frame)
    private let stickerButton = PTGGrayButton(type: .sticker)
    
    var frameButtonTapped: AnyPublisher<Void, Never> {
        return frameButton.tapPublisher
    }
    
    var stickerButtonTapped: AnyPublisher<Void, Never> {
        return stickerButton.tapPublisher
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addViews()
        setupConstraints()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        addSubview(stackView)
        
        [frameButton, stickerButton].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setupConstraints() {
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(32)
            $0.verticalEdges.equalToSuperview().inset(14)
        }
    }
    
    // TODO: nextButton background primaryColor로 변경 예정
    private func configureUI() {
        backgroundColor = .clear
        
        stackView.spacing = 16
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
    }
}
