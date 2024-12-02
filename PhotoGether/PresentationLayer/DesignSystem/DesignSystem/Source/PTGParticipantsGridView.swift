import UIKit
import SnapKit

public enum ParticipantPosition: Int {
    case topLeading
    case bottomTrailing
    case topTrailing
    case bottomLeading
    
    public init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .topLeading
        case 1: self = .bottomTrailing
        case 2: self = .topTrailing
        case 3: self = .bottomLeading
        default: return nil
        }
    }
}

public final class PTGParticipantsGridView: UIView {
    public private(set) var topLeadingParticipantView = PTGParticipantsView()
    public private(set) var topTrailingParticipantView = PTGParticipantsView()
    public private(set) var bottomLeadingParticipantView = PTGParticipantsView()
    public private(set) var bottomTrailingParticipantView = PTGParticipantsView()
    
    private let vStackView = UIStackView()
    private let topHStackView = UIStackView()
    private let bottomHStackView = UIStackView()
    
    public init() {
        super.init(frame: .zero)
        addViews()
        setConstraints()
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateParticipantView(view: UIView, position: ParticipantPosition) {
        switch position {
        case .topLeading:
            self.topLeadingParticipantView.setVideoView(view)
        case .topTrailing:
            self.topTrailingParticipantView.setVideoView(view)
        case .bottomLeading:
            self.bottomLeadingParticipantView.setVideoView(view)
        case .bottomTrailing:
            self.bottomTrailingParticipantView.setVideoView(view)
        }
    }
    
    public func updateParticipantNickname(nickName: String, position: ParticipantPosition) {
        switch position {
        case .topLeading:
            self.topLeadingParticipantView.setNickname(nickName)
        case .topTrailing:
            self.topTrailingParticipantView.setNickname(nickName)
        case .bottomLeading:
            self.bottomLeadingParticipantView.setNickname(nickName)
        case .bottomTrailing:
            self.bottomTrailingParticipantView.setNickname(nickName)
        }
    }
    
    private func addViews() {
        addSubview(vStackView)
        
        vStackView.addArrangedSubview(topHStackView)
        vStackView.addArrangedSubview(bottomHStackView)
        
        topHStackView.addArrangedSubview(topLeadingParticipantView)
        topHStackView.addArrangedSubview(topTrailingParticipantView)
        
        bottomHStackView.addArrangedSubview(bottomLeadingParticipantView)
        bottomHStackView.addArrangedSubview(bottomTrailingParticipantView)
    }
    
    private func setConstraints() {
        vStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureUI() {
        self.backgroundColor = PTGColor.gray90.color
        
        vStackView.axis = .vertical
        vStackView.spacing = Constants.itemSpacing
        vStackView.distribution = .fillEqually
        
        [topHStackView,
         bottomHStackView
        ].forEach {
            $0.axis = .horizontal
            $0.spacing = Constants.itemSpacing
            $0.distribution = .fillEqually
        }
        
        [topLeadingParticipantView,
         topTrailingParticipantView,
         bottomLeadingParticipantView,
         bottomTrailingParticipantView
        ].forEach {
            $0.backgroundColor = PTGColor.gray90.color
        }
    }
}

extension PTGParticipantsGridView {
    private enum Constants {
        static let itemSpacing: CGFloat = 11
    }
}
