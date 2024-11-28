import DesignSystem
import PhotoGetherDomainInterface
import UIKit

protocol StickerViewActionDelegate: AnyObject {
    func stickerView(_ stickerView: StickerView, didTap id: UUID)
    func stickerView(_ stickerView: StickerView, didTapDelete id: UUID)
}

final class StickerView: UIImageView {
    private let nicknameLabel = UILabel()
    private let layerView = UIView()
    private let deleteButton = UIButton()

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
        setupTarget()
        addViews()
        setupConstraints()
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        [nicknameLabel, layerView, deleteButton].forEach {
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(snp.bottom)
            $0.centerX.equalToSuperview()
        }
        
        layerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.bottom.equalTo(snp.top).inset(10)
            $0.trailing.equalTo(snp.trailing).offset(10)
            $0.width.height.equalTo(20)
        }
    }
    
    private func configureUI() {
        let deleteButtonImage = PTGImage.xmarkIcon.image
        layerView.layer.borderWidth = 1
        layerView.layer.borderColor = PTGColor.primaryGreen.color.cgColor
        layerView.isUserInteractionEnabled = false
        
        deleteButton.setImage(deleteButtonImage, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.clipsToBounds = true
        
        setImage(to: sticker.image)
        
        sticker.owner != nil
        ? (layerView.isHidden = false)
        : (layerView.isHidden = true)
        
        _ = sticker.owner != user
        ? (deleteButton.isHidden = true, deleteButton.isUserInteractionEnabled = false)
        : (deleteButton.isHidden = false, deleteButton.isUserInteractionEnabled = true)
    }
    
    private func setupTapGesture() {
        isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupTarget() {
        deleteButton.addTarget(
            self,
            action: #selector(deleteButtonTapped),
            for: .touchUpInside
        )
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
            layerView.isHidden = false
        } else {
            nicknameLabel.text = nil
            layerView.isHidden = true
        }
        
        _ = sticker.owner != user
        ? (deleteButton.isHidden = true, deleteButton.isUserInteractionEnabled = false)
        : (deleteButton.isHidden = false, deleteButton.isUserInteractionEnabled = true)
    }
    
    private func setImage(to urlString: String) {
        guard let url = URL(string: urlString) else { return }
        Task { await self.setAsyncImage(url) }
    }
    
    @objc private func handleTap() {
        delegate?.stickerView(self, didTap: sticker.id)
    }
    
    @objc private func deleteButtonTapped() {
        delegate?.stickerView(self, didTapDelete: sticker.id)
    }
    
    func update(with sticker: StickerEntity) {
        updateOwner(to: sticker.owner)
        updateFrame(to: sticker.frame)
    }
}
