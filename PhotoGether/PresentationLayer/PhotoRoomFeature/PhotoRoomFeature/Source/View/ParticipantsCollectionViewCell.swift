import UIKit
import BaseFeature
import DesignSystem

public final class ParticipantsCollectionViewCell: UICollectionViewCell {
    private let nicknameLabel = PTGPaddingLabel()
    private weak var videoView: UIView?
    
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
    
    public func setVideoView(_ videoView: UIView) {
        self.videoView = videoView
        
        guard let videoView = self.videoView else { return }
        
        contentView.insertSubview(videoView, belowSubview: nicknameLabel)
        
        videoView.snp.makeConstraints {
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
        backgroundColor = .yellow
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
