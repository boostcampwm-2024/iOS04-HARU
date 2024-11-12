import UIKit
import SnapKit

public final class PTGPrimaryButton: UIButton {
    private let buttonLabel = UILabel()

    public init() {
        super.init(frame: .zero)
        
        addViews()
        setupConstraints()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        addSubview(buttonLabel)
    }
    
    private func setupConstraints() {
        buttonLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    private func configureUI() {
        backgroundColor = .primaryGreen
        layer.cornerRadius = 8
        
        buttonLabel.font = .systemFont(ofSize: 18, weight: .regular)
        buttonLabel.textColor = .gray85
        buttonLabel.textAlignment = .center
    }
    
    public func setTitle(to title: String) {
        buttonLabel.text = title
    }
}
