import UIKit
import BaseFeature
import DesignSystem

public final class ParticipantsCollectionViewCell: UICollectionViewCell {
    private var nicknameLabel: UIView!
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
    
    private func removeTargetView(_ targetView: UIView?) {
        contentView.subviews
            .filter { $0 === targetView }
            .forEach { $0.removeFromSuperview() }
    }
    
    public func setNickname(_ nickname: String) {
        removeTargetView(self.nicknameLabel)
        
        let newNickNameLabel = NickNameLabelView(nickName: nickname).uiView
        newNickNameLabel.backgroundColor = .clear
        //newNickNameLabel.clipsToBounds = true
        self.nicknameLabel = newNickNameLabel
        
        guard let nicknameLabel = self.nicknameLabel else { return }
        
        contentView.addSubview(nicknameLabel)

        nicknameLabel.snp.makeConstraints {
            //$0.width.equalTo(Constants.nicknameLabelWidth)
            $0.height.equalTo(Constants.nicknameLabelHeight)
            $0.top.equalToSuperview().offset(Constants.nicknameLabelTopSpacing)
            $0.trailing.equalToSuperview().inset(Constants.nicknameLabelTrailingSpacing)
        }
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
//        contentView.addSubview(nicknameLabel)
    }
    
    private func setConstraints() {
//        nicknameLabel.snp.makeConstraints {
//            $0.width.equalTo(Constants.nicknameLabelWidth)
//            $0.height.equalTo(Constants.nicknameLabelHeight)
//            $0.top.equalToSuperview().offset(Constants.nicknameLabelTopSpacing)
//            $0.trailing.equalToSuperview().inset(Constants.nicknameLabelTrailingSpacing)
//        }
    }
    
    private func configureUI() {
        backgroundColor = .yellow
//        UILabel().font = .systemFont(ofSize: 11)
//        UILabel().setKern()
//        UILabel().textColor = .white.withAlphaComponent(0.8)
//        UILabel().backgroundColor = UIColor.black.withAlphaComponent(0.4)
//        nicknameLabel.clipsToBounds = true
//        nicknameLabel.layer.cornerRadius = 20
        
    }
}

extension ParticipantsCollectionViewCell {
    private enum Constants {
        static let nicknameLabelWidth: CGFloat = 40
        static let nicknameLabelHeight: CGFloat = 20
        static let nicknameLabelTopSpacing: CGFloat = 8
        static let nicknameLabelTrailingSpacing: CGFloat = 8
        static let nicknameLabelVerticalInset: CGFloat = 3.5
        static let nicknameLabelHorizontalInset: CGFloat = 8
    }
}
