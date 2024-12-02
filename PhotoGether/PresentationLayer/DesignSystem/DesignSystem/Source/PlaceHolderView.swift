import UIKit
import SnapKit

public final class PTGParticipantsPlaceHolderView: UIView {
    private let label = UILabel()
    
    public init() {
        super.init(frame: .zero)
        addViews()
        setupConstraints()
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        self.addSubview(label)
    }
    
    private func setupConstraints() {
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.backgroundColor = PTGColor.gray90.color
        label.text = "Photo Gether"
        label.font = .PTGFont(size: 20, weight: .regular)
        label.textColor = .white
    }
}
