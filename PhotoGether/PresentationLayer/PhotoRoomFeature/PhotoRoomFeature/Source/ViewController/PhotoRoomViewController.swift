import UIKit
import BaseFeature
import Combine
import DesignSystem
import EditPhotoRoomFeature
import PhotoGetherDomain
import PhotoGetherData
import PhotoGetherDomainInterface

public final class PhotoRoomViewController: BaseViewController, ViewControllerConfigure {
    private let navigationView = UIView()
    var participantsGridView: PTGParticipantsGridView!
    var connectionRepsitory: ConnectionRepository
    private let photoRoomBottomView: PhotoRoomBottomView
    private var isHost: Bool
    
    
    private let input = PassthroughSubject<PhotoRoomViewModel.Input, Never>()
    
    private let viewModel: PhotoRoomViewModel
    
    public init(
        connectionRepsitory: ConnectionRepository,
        viewModel: PhotoRoomViewModel,
        isHost: Bool
    ) {
        self.connectionRepsitory = connectionRepsitory
        self.viewModel = viewModel
        self.isHost = isHost
        self.photoRoomBottomView = PhotoRoomBottomView(isHost: isHost)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        addViews()
        setupConstraints()
        configureUI()
        bindInput()
        bindOutput()
        bindNoti()
    }
    
    private func bindNoti() {
        NotificationCenter.default.publisher(for: .receiveStartCountDown)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
            self?.isHost = false
            self?.input.send(.cameraButtonTapped)
        }.store(in: &cancellables)
    }
    
    public func setParticipantsGridView(_ participantsGridView: PTGParticipantsGridView) {
        self.participantsGridView = participantsGridView
    }
    
    public func addViews() {
        [navigationView, participantsGridView, photoRoomBottomView].forEach {
            view.addSubview($0)
        }
    }
    
    public func setupConstraints() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(Constants.navigationHeight)
        }
        
        participantsGridView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(photoRoomBottomView.snp.top)
        }
        
        photoRoomBottomView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(Constants.bottomViewHeight)
        }
    }
    
    public func configureUI() {
        navigationView.backgroundColor = PTGColor.gray90.color
    }
    
    public func bindInput() {
        photoRoomBottomView.cameraButtonTapped
            .filter { [weak self] in
                return self?.isHost ?? false
            }
            .sink { [weak self] _ in
                NotificationCenter.default.post(name: .startCountDown, object: nil)
                self?.input.send(.cameraButtonTapped)
            }
            .store(in: &cancellables)
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] in
            guard let self else { return }
            switch $0 {
            case .timer(let count):
                self.photoRoomBottomView.setCameraButtonTimer(count)
            case .timerCompleted(let images):
                self.photoRoomBottomView.stopCameraButtonTimer()
                let viewController = UIViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        .store(in: &cancellables)
    }
}

extension PhotoRoomViewController {
    private enum Constants {
        static let bottomViewHeight: CGFloat = 80
        static let navigationHeight: CGFloat = 48
    }
}
