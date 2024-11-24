import Combine
import DesignSystem
import PhotoGetherDomainInterface
import UIKit

final class StickerView: UIImageView {
    private let tapPublisher = PassthroughSubject<Void, Never>()
    private let nicknameLabel = UILabel()

    private var sticker: StickerEntity

    private var cancellables = Set<AnyCancellable>()

    init(sticker: StickerEntity) {
        self.sticker = sticker
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
        tapPublisher.send(())
    }
    
    func tapHandler(_ completion: @escaping (UUID) -> Void) {
        tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                completion(sticker.id)
            }
            .store(in: &cancellables)
    }
    
    func update(with sticker: StickerEntity) {
        updateOwner(to: sticker.owner)
        updateFrame(to: sticker.frame)
    }
}
