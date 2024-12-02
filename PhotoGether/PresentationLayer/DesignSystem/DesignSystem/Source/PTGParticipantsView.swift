import UIKit
import SnapKit
import CoreModule

public final class PTGParticipantsView: UIView {
    private let nicknameLabel = PTGPaddingLabel()
    private let placeholderView = PTGParticipantsPlaceHolderView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        setConstraints()
        configureUI()
        nicknameLabel.isHidden = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func setNickname(_ nickname: String) {
        nicknameLabel.text = nickname
        nicknameLabel.isHidden = false
    }
    
    public func setVideoView(_ videoView: UIView) {
        if self.subviews.count == 2 { // 처음 설정하는 경우
            insertSubview(videoView, belowSubview: nicknameLabel)
        } else if self.subviews.count >= 3 { // 덮어씌우는 경우
            if removeAlreadyExistVideoView() {
                insertSubview(videoView, belowSubview: nicknameLabel)
            } else {
                print("기존 VideoView를 찾지 못했습니다.")
            }
        } else {
            print("SubView 구성이 맞지 않습니다. subView Count: \(subviews.count)")
        }
        
        videoView.clipsToBounds = true
        videoView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    public func removeAlreadyExistVideoView() -> Bool {
        guard let alreadyExistVideoView = subviews[safe: 1] else { return false }
        guard alreadyExistVideoView === nicknameLabel else { return false }
        guard alreadyExistVideoView === placeholderView else { return false }
        alreadyExistVideoView.removeFromSuperview()
        return true
    }
    
    private func addViews() {
        addSubview(placeholderView)
        addSubview(nicknameLabel)
    }
    
    private func setConstraints() {
        placeholderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
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
        
        nicknameLabel.font = .systemFont(ofSize: 11)
        nicknameLabel.textColor = .white.withAlphaComponent(0.8)
        nicknameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        nicknameLabel.layer.cornerRadius = 10
        nicknameLabel.clipsToBounds = true
    }
}

extension PTGParticipantsView {
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
