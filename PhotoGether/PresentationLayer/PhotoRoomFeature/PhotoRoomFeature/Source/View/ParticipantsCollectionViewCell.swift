import UIKit
import BaseFeature
import DesignSystem

public final class ParticipantsCollectionViewCell: UICollectionViewCell {
    private let nicknameLabel = PTGPaddingLabel()
    private weak var view: UIView?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        setConstraints()
        configureUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func setNickname(_ nickname: String) {
        nicknameLabel.text = nickname
    }
    
    public func setView(_ view: UIView) {
        self.view = view
        
        guard let view = self.view else { return }
        
        contentView.insertSubview(view, belowSubview: nicknameLabel)
        
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func addViews() {
        contentView.addSubview(nicknameLabel)
    }
    
    private func setConstraints() {
        nicknameLabel.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(Constants.nicknameLabelMinWidth)
            $0.width.lessThanOrEqualTo(Constants.nicknameLabelMaxWidth)
            $0.height.equalTo(Constants.nicknameLabelHeight)
            $0.top.equalToSuperview().offset(Constants.nicknameLabelTopSpacing)
            $0.trailing.equalToSuperview().inset(Constants.nicknameLabelTrailingSpacing)
        }
    }
    
    private func configureUI() {
        backgroundColor = PTGColor.gray50.color
        contentView.clipsToBounds = true

        nicknameLabel.font = .systemFont(ofSize: 11)
        nicknameLabel.setKern()
        nicknameLabel.textColor = .white.withAlphaComponent(0.8)
        nicknameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        nicknameLabel.layer.cornerRadius = 10
        nicknameLabel.clipsToBounds = true
    }
}

extension ParticipantsCollectionViewCell {
    private enum Constants {
        static let nicknameLabelMinWidth: CGFloat = 40
        static let nicknameLabelMaxWidth: CGFloat = 120
        static let nicknameLabelHeight: CGFloat = 20
        static let nicknameLabelTopSpacing: CGFloat = 8
        static let nicknameLabelTrailingSpacing: CGFloat = 8
        static let nicknameLabelVerticalInset: CGFloat = 3.5
        static let nicknameLabelHorizontalInset: CGFloat = 8
    }
}
