import UIKit
import BaseFeature
import DesignSystem

public final class ParticipantsCollectionViewCell: UICollectionViewCell {
    public static let reuseIdentifier = "\(ParticipantsCollectionViewCell.self)"
    
    private let nicknameLabel = UILabel()
    private var videoView = UIView()
    
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
        self.nicknameLabel.text = nickname
    }
    
    public func setVideoView(_ videoView: UIView) {
        self.videoView = videoView
    }
    
    private func addViews() {
        [videoView, nicknameLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setConstraints() {
        videoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.width.equalTo(Constants.nicknameLabelWidth)
            $0.height.equalTo(Constants.nicknameLabelHeight)
            $0.top.equalToSuperview().offset(Constants.nicknameLabelTopSpacing)
            $0.trailing.equalToSuperview().inset(Constants.nicknameLabelTrailingSpacing)
        }
    }
    
    private func configureUI() {
        nicknameLabel.font = .systemFont(ofSize: 11)
        nicknameLabel.setKern()
        nicknameLabel.textColor = .white.withAlphaComponent(0.8)
        nicknameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        nicknameLabel.layer.cornerRadius = 20
    }
}

extension ParticipantsCollectionViewCell {
    private enum Constants {
        static let nicknameLabelWidth: CGFloat = 40
        static let nicknameLabelHeight: CGFloat = 20
        static let nicknameLabelTopSpacing: CGFloat = 8
        static let nicknameLabelTrailingSpacing: CGFloat = 8
    }
}
