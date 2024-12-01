import DesignSystem
import PhotoGetherDomainInterface
import UIKit

protocol StickerViewActionDelegate: AnyObject {
    func stickerView(_ stickerView: StickerView, didTap id: UUID)
    func stickerView(_ stickerView: StickerView, didTapDelete id: UUID)
    func stickerView(_ stickerView: StickerView, willBeginDraging sticker: StickerEntity)
    func stickerView(_ stickerView: StickerView, didDrag sticker: StickerEntity)
    func stickerView(_ stickerView: StickerView, didEndDrag sticker: StickerEntity)
}

final class StickerView: UIView {
    private let nicknameLabel = UILabel()
    private let imageView = UIImageView()
    private let layerView = UIView()
    private let deleteButton = UIButton()
    private let panGestureRecognizer = UIPanGestureRecognizer()

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
        setupGesture()
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
        [imageView, nicknameLabel, layerView, deleteButton].forEach {
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(snp.bottom)
            $0.trailing.equalTo(snp.trailing)
        }
        
        layerView.snp.makeConstraints {
            $0.edges.equalTo(imageView)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.width.height.equalTo(snp.width).multipliedBy(0.3)
        }
    }
    
    private func configureUI() {
        let deleteButtonImage = PTGImage.xmarkIcon.image
        layerView.layer.borderWidth = 1
        layerView.layer.borderColor = PTGColor.primaryGreen.color.cgColor
        layerView.isUserInteractionEnabled = false
        
        deleteButton.setImage(deleteButtonImage, for: .normal)
        deleteButton.layer.cornerRadius = deleteButton.bounds.width / 2
        deleteButton.clipsToBounds = true
        
        setImage(to: sticker.image)
        
        sticker.owner != nil
        ? (layerView.isHidden = false)
        : (layerView.isHidden = true)
        
        _ = sticker.owner != user
        ? (deleteButton.isHidden = true, deleteButton.isUserInteractionEnabled = false)
        : (deleteButton.isHidden = false, deleteButton.isUserInteractionEnabled = true)
    }
    
    private func setupGesture() {
        isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
        
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let initialPoint = sticker.frame.origin
        let translationPoint = gesture.translation(in: self)
        let changedX = initialPoint.x + translationPoint.x
        let changedY = initialPoint.y + translationPoint.y
        let traslationStickerPoint = CGPoint(x: changedX, y: changedY)
        
        panGestureRecognizer.setTranslation(.zero, in: self)
        
        let newFrame = CGRect(origin: traslationStickerPoint, size: sticker.frame.size)
        
        switch gesture.state {
        case .began:
            updateFrame(to: newFrame)
            updateOwner(to: user)
            delegate?.stickerView(self, willBeginDraging: sticker)
        case .changed:
            updateFrame(to: newFrame)
            delegate?.stickerView(self, didDrag: sticker)
        case .ended:
            delegate?.stickerView(self, didEndDrag: sticker)
        default: break
        }
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
        
        updatePanGestureState()
    }
    
    private func updatePanGestureState() {
        if sticker.owner == user || sticker.owner == nil {
            panGestureRecognizer.isEnabled = true
        } else {
            panGestureRecognizer.isEnabled = false
        }
    }
    
    private func setImage(to urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        Task { [weak self] in
            guard let (data, _) = try? await URLSession.shared.data(from: url)
            else { return }
            
            self?.imageView.image = UIImage(data: data)
        }
    }
    
    @objc private func handleTap() {
        delegate?.stickerView(self, didTap: sticker.id)
    }
    
    @objc private func deleteButtonTapped() {
        delegate?.stickerView(self, didTapDelete: sticker.id)
    }
    
    func update(with sticker: StickerEntity) {
        switch panGestureRecognizer.state {
        case .began, .changed:
            return
        default:
            updateOwner(to: sticker.owner)
            
            if sticker.owner != user {
                updateFrame(to: sticker.frame)
            }
        }
    }
}
