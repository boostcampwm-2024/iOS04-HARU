import UIKit
import Combine
import DesignSystem

final class PhotoRoomBottomView: UIView {
    private let filterButton = UIButton()
    private let switchCameraButton = UIButton()
    private let cameraButton: CameraButton
    private let isHost: Bool
    
    var cameraButtonTapped: AnyPublisher<Void, Never> {
        cameraButton.tapPublisher
            .throttle(for: .seconds(Constants.throttleTime), scheduler: RunLoop.main, latest: false)
            .eraseToAnyPublisher()
    }
    
    // MARK: init
    init(isHost: Bool) {
        self.isHost = isHost
        self.cameraButton = CameraButton(isHost: isHost)
        super.init(frame: .zero)
        
        addViews()
        setupConstraints()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews() {
        [filterButton, switchCameraButton, cameraButton].forEach {
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        filterButton.snp.makeConstraints {
            $0.height.width.equalTo(Constants.iconButtonSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(Constants.bottomLeadingSpacing)
        }
        
        switchCameraButton.snp.makeConstraints {
            $0.height.width.equalTo(Constants.iconButtonSize)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Constants.bottomTrailingSpacing)
        }
        
        cameraButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(CameraButton.Constants.buttonSize)
        }
    }
    
    private func configureUI() {
        filterButton.setImage(PTGImage.filterIcon.image, for: .normal)
        filterButton.imageView?.tintColor = isHost ? .white : PTGColor.gray85.color
        
        switchCameraButton.setImage(PTGImage.switchIcon.image, for: .normal)
    }
    
    func setCameraButtonTimer(_ count: Int) {
        cameraButton.configureTimer(count)
    }
    
    func stopCameraButtonTimer() {
        cameraButton.stopTimer()
    }
    
    func highlightCameraButton() {
        cameraButton.layer.borderColor = PTGColor.primaryGreen.color.cgColor
    }
}

extension PhotoRoomBottomView {
    private enum Constants {
        static let iconButtonSize: CGFloat = 40
        static let bottomLeadingSpacing: CGFloat = 53
        static let bottomTrailingSpacing: CGFloat = 53
        static let throttleTime: CGFloat = 4
    }
}
