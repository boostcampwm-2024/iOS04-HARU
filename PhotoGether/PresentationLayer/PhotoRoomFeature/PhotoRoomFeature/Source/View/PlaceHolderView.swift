import UIKit
import DesignSystem
import SnapKit
import BaseFeature

public final class PlaceHolderView: UIView {
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
    
    public func setText(_ text: String) {
        self.label.text = text
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
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        label.setKern()
    }
}
