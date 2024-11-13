import Combine
import DesignSystem
import UIKit

final class SharePhotoBottomView: UIView {
    private let shareButton = PTGCircleButton(type: .share)
    private let saveButton = PTGPrimaryButton()
    
    var shareButtonTapped: AnyPublisher<Void, Never> {
        return shareButton.tapPublisher
    }
    
    var saveButtonTapped: AnyPublisher<Void, Never> {
        return saveButton.tapPublisher
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
        [shareButton, saveButton].forEach {
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        shareButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(14)
            $0.width.height.equalTo(52)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.equalTo(shareButton.snp.trailing).offset(16)
            $0.verticalEdges.equalTo(shareButton)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func configureUI() {
        backgroundColor = .clear
        saveButton.setTitle(to: "저장하기")
    }
}
