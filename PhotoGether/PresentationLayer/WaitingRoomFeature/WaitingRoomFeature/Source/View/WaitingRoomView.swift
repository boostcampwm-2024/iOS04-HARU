import UIKit
import DesignSystem
import BaseFeature

enum ParticipantPosition {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

final class WaitingRoomView: UIView {
    let bottomBarView = UIView()
    let micButton = PTGMicButton(micState: .on)
    let linkButton = PTGCircleButton(type: .link)
    let startButton = PTGPrimaryButton()
    
    private(set) var topLeadingView = UIView()
    private(set) var topTrailingView = UIView()
    private(set) var bottomLeadingView = UIView()
    private(set) var bottomTrailingView = UIView()
    
    private let vStackView = UIStackView()
    private let topHStackView = UIStackView()
    private let bottomHStackView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        addViews()
        setConstraints()
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateParticipantView(view: UIView, position: ParticipantPosition) {
        switch position {
        case .topLeading:
            self.topLeadingView.addSubview(view)
        case .topTrailing:
            self.topTrailingView.addSubview(view)
        case .bottomLeading:
            self.bottomLeadingView.addSubview(view)
        case .bottomTrailing:
            self.bottomTrailingView.addSubview(view)
        }
        view.clipsToBounds = true
        view.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    func toggleMicButtonState() {
        micButton.toggleMicState()
    }
    
    func updateStartButtonTitle(count: Int) {
        guard let title = StartButtonTitle(from: count) else { return }
        startButton.setTitle(to: title.rawValue)
    }
}

private extension WaitingRoomView {
    func addViews() {
        [bottomBarView, micButton, vStackView].forEach { addSubview($0) }
        [linkButton, startButton].forEach { bottomBarView.addSubview($0) }
        
        [topLeadingView, topTrailingView].forEach { topHStackView.addArrangedSubview($0) }
        [bottomLeadingView, bottomTrailingView].forEach { bottomHStackView.addArrangedSubview($0) }
        [topHStackView, bottomHStackView].forEach { vStackView.addArrangedSubview($0) }
    }
    
    func setConstraints() {
        let horizontalSpacing = Constants.sectionHorizontalSpacing * 2
        let itemWidth = (UIScreen.main.bounds.width - horizontalSpacing - Constants.itemSpacing) / 2
        let itemHeight = itemWidth * Constants.sizeMultiplier
        let topOffset: CGFloat = APP_HEIGHT() > 667 ? 44 : 0 // 최소사이즈 기기 SE2 기준
        
        vStackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(topOffset)
            $0.horizontalEdges.equalToSuperview().inset(Constants.sectionHorizontalSpacing)
            $0.bottom.equalTo(bottomBarView.snp.top)
        }
        
        bottomBarView.snp.makeConstraints {
            $0.height.equalTo(Constants.bottomBarViewHeight)
            $0.horizontalEdges.equalToSuperview()
                .inset(Constants.bottomBarViewHorizontalInset)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        linkButton.snp.makeConstraints {
            $0.size.equalTo(Constants.circleButtonSize)
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        startButton.snp.makeConstraints {
            $0.height.equalTo(Constants.startButtonHeight)
            $0.leading.equalTo(linkButton.snp.trailing)
                .offset(Constants.bottomBarViewHorizontalInset)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        micButton.snp.makeConstraints {
            $0.size.equalTo(Constants.circleButtonSize)
            $0.leading.equalTo(bottomBarView.snp.leading)
            $0.bottom.equalTo(bottomBarView.snp.top)
                .offset(Constants.micButtonBottomSpacing)
        }
    }
    
    func configureUI() {
        self.backgroundColor = PTGColor.gray90.color
        
        vStackView.axis = .vertical
        vStackView.spacing = Constants.itemSpacing
        vStackView.distribution = .fillEqually
        
        [topHStackView, bottomHStackView].forEach {
            $0.axis = .horizontal
            $0.spacing = Constants.itemSpacing
            $0.distribution = .fillEqually
        }
        
        [topLeadingView,
        topTrailingView,
        bottomLeadingView,
         bottomTrailingView
        ].forEach { $0.backgroundColor = PTGColor.gray50.color }

        startButton.setTitle(to: StartButtonTitle.one.rawValue)
    }
}

extension WaitingRoomView {
    private enum StartButtonTitle: String {
        case one = "혼자서 촬영시작"
        case two = "둘이서 촬영시작"
        case three = "셋이서 촬영시작"
        case four = "넷이서 촬영시작"
        
        init?(from count: Int) {
            switch count {
            case 1: self = .one
            case 2: self = .two
            case 3: self = .three
            case 4: self = .four
            default: return nil
            }
        }
    }
    
    private enum Constants {
        static let bottomBarViewHeight: CGFloat = 80
        static let bottomBarViewHorizontalInset: CGFloat = 16
        static let circleButtonSize: CGSize = CGSize(width: 52, height: 52)
        static let startButtonHeight: CGFloat = 52
        static let micButtonBottomSpacing: CGFloat = -4
        
        static let sizeMultiplier: CGFloat = 290 / 179 // 피그마 디자인에 따른 세로/가로 비율입니다.
        static let sectionHorizontalSpacing: CGFloat = 12
        static let itemSpacing: CGFloat = 11
    }
}
