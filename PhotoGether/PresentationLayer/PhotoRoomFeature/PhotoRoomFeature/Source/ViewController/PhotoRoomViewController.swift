import UIKit
import BaseFeature
import Combine
import DesignSystem

public class PhotoRoomViewController: BaseViewController, ViewControllerConfigure {
    private let navigationView = UIView()
    private let participantsViewController = ParticipantsCollectionViewController()
    private let photoRoomBottomView: PhotoRoomBottomView
    private let isHost: Bool
    
    private let input = PassthroughSubject<PhotoRoomViewModel.Input, Never>()
    
    private let viewModel = PhotoRoomViewModel()
    
    public init(isHost: Bool) {
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
        
        addViews()
        setupConstraints()
        configureUI()
        bindInput()
        bindOutput()
    }
    
    public func addViews() {
        self.addChild(participantsViewController)
        participantsViewController.didMove(toParent: self)
        
        [navigationView, participantsViewController.view, photoRoomBottomView].forEach {
            view.addSubview($0)
        }
    }
    
    public func setupConstraints() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(Constants.navigationHeight)
        }
        
        participantsViewController.view.snp.makeConstraints {
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
        navigationView.backgroundColor = PTGColor.gray50.color
    }
    
    public func bindInput() {
        // MARK: Host에 필요한 Input만 guard문 아래에
        guard isHost else { return }
        
        photoRoomBottomView.cameraButtonTapped
            .sink { [weak self] _ in
                self?.input.send(.cameraButtonTapped)
            }
            .store(in: &cancellables)
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] in
            switch $0 {
            case .timer(let count):
                self?.photoRoomBottomView.setCameraButtonTimer(count)
            case .timerCompleted:
                self?.photoRoomBottomView.stopCameraButtonTimer()
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
