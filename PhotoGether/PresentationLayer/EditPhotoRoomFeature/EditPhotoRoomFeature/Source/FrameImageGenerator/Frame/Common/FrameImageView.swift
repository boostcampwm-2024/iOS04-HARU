import UIKit

class FrameImageView: UIView {
    private(set) var images: [UIImage]
    private(set) var imageViews: [UIImageView] = []
    var participants: Participant { Participant(count: images.count) }
    
    init(images: [UIImage]) {
        self.images = images
        super.init(frame: .zero)
        setupImageViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageViews() {
        let maxImageCount = participants.rawValue
        imageViews = (0..<maxImageCount).map { _ in UIImageView() }
        imageViews.forEach {
            addSubview($0)
            $0.backgroundColor = .clear
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
    }
    
    func addViews() { }
    
    func setupConstraints() { }
    
    func configureUI() { }
    
    enum Participant: Int {
        case single = 1, pair, trio, quad
        
        init(count: Int) {
            switch count {
            case 1:
                self = .single
            case 2:
                self = .pair
            case 3:
                self = .trio
            case 4:
                self = .quad
            default:
                fatalError("Invalid participant count: \(count). Valid counts are 1, 2, 3, or 4.")
            }
        }
    }
}
