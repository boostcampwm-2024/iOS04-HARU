import DesignSystem
import PhotoGetherDomainInterface
import UIKit

protocol StickerViewActionDelegate: AnyObject {
    func stickerView(_ stickerView: StickerView, didTap id: UUID)
}

final class StickerView: UIImageView {
    private let nicknameLabel = UILabel()

    private var sticker: StickerEntity
    private let user: String

    weak var delegate: StickerViewActionDelegate?
    
    init(
        sticker: StickerEntity,
        user: String
    ) {
        self.sticker = sticker
        self.user = user
        super.init(frame: sticker.frame)
        setupTapGesture()
        addViews()
        setupConstraints()
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        addSubview(nicknameLabel)
    }
    
    private func setupConstraints() {
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(snp.bottom)
            $0.trailing.equalTo(snp.trailing)
        }
    }
    
    private func configureUI() {
        layer.borderColor = PTGColor.primaryGreen.color.cgColor
        setImage(to: sticker.image)
        
        sticker.owner != nil
        ? (layer.borderWidth = 1)
        : (layer.borderWidth = 0)
    }

    private func setupTapGesture() {
        isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func updateFrame(to frame: CGRect) {
        guard sticker.frame != frame else { return }
        
        sticker.updateFrame(to: frame)
        self.frame = frame
    }
    
    private func updateOwner(to owner: String?) {
        guard sticker.owner != owner else { return }
        
        sticker.updateOwner(to: owner)
        if let owner = owner {
            nicknameLabel.text = owner
            layer.borderWidth = 1
        } else {
            nicknameLabel.text = nil
            layer.borderWidth = 0
        }
    }
    
    private func setImage(to urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        Task { [weak self] in
            guard let (data, _) = try? await URLSession.shared.data(from: url)
            else { return }
            
            self?.image = UIImage(data: data)
        }
    }
    
    @objc private func handleTap() {
        delegate?.stickerView(self, didTap: sticker.id)
    }
    
    func update(with sticker: StickerEntity) {
        updateOwner(to: sticker.owner)
        updateFrame(to: sticker.frame)
    }
}
