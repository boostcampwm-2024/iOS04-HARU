import UIKit

// TODO: 이미지가 Repo로 부터 도착하면 image 주입
// TODO: Cell 탭할 때 해당 이모지 화면에 추가 + 이벤트 허브 태우기

final class StickerCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addViews()
        self.setupConstraints()
        self.configureUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func addViews() {
        [imageView].forEach { self.addSubview($0) }
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureUI() {
        imageView.backgroundColor = .red
    }
}
