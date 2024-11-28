
import UIKit
import DesignSystem
import Combine
import BaseFeature
import PhotoGetherDomainInterface
import EditPhotoRoomFeature

final class OfferTempViewController2: BaseViewController, ViewControllerConfigure {
    private let stackView = UIStackView()
    private let hostButton = UIButton()
    private let guestButton = UIButton()
    
    private let hostViewController: EditPhotoRoomHostViewController
    private let guestViewController: EditPhotoRoomGuestViewController
    
    init(
        hostViewController: EditPhotoRoomHostViewController,
        guestViewController: EditPhotoRoomGuestViewController
    ) {
        self.hostViewController = hostViewController
        self.guestViewController = guestViewController
        super.init(nibName: nil, bundle: nil)
        
        addViews()
        setupConstraints()
        configureUI()
        bindOutput()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        view.addSubview(stackView)
        [hostButton, guestButton]
            .forEach { stackView.addArrangedSubview($0) }
    }
    
    func setupConstraints() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(272)
        }
        
        [hostButton, guestButton].forEach {
            $0.snp.makeConstraints {
                $0.width.equalTo(200)
                $0.height.equalTo(80)
            }
        }
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        
        [hostButton, guestButton].forEach {
            $0.setTitleColor(PTGColor.gray90.color, for: .normal)
            $0.backgroundColor = PTGColor.gray50.color
        }
        
        hostButton.setTitle("HOST", for: .normal)
        guestButton.setTitle("GUEST", for: .normal)
    }
    
    func bindOutput() {
        hostButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                navigationController?.pushViewController(hostViewController, animated: true)
            }
            .store(in: &cancellables)
        
        guestButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                self.navigationController?.pushViewController(guestViewController, animated: true)
            }
            .store(in: &cancellables)
    }
}
