import UIKit

import SnapKit

public final class ParticipantsCollectionViewCell: UICollectionViewCell {
    public static let reuseIdentifier = "\(ParticipantsCollectionViewCell.self)"
    
    private var videoView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        setConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public func configure(_ view: UIView) {
        self.videoView = view
    }
    
    private func addViews() {
        contentView.addSubview(videoView)
    }
    
    private func setConstraints() {
        videoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
