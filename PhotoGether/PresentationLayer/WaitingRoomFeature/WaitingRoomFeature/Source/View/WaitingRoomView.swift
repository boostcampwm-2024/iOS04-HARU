import UIKit
import DesignSystem

final class WaitingRoomView: UIView {
    let bottomBarView = UIView()
    let micButton = PTGMicButton(micState: .on)
    let linkButton = PTGCircleButton(type: .link)
    let startButton = PTGPrimaryButton()
    
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
        [bottomBarView, micButton].forEach { addSubview($0) }
        [linkButton, startButton].forEach {
            bottomBarView.addSubview($0)
        }
    }
    
    func setConstraints() {
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
        
        startButton.setTitle(to: StartButtonTitle.one.rawValue)
    }
}

extension WaitingRoomView {
    private enum StartButtonTitle: String {
        case one = "촬영시작"
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
    }
}
