import UIKit
import Combine
import BaseFeature
import DesignSystem
import PhotoGetherDomainInterface

public final class EnterLoadingViewController: BaseViewController, ViewControllerConfigure {
    private let viewModel: EnterLoadingViewModel
    private let waitingRoomViewController: WaitingRoomViewController
    private let label = UILabel()
    private let activityIndicator = UIActivityIndicatorView()
    private let input = PassthroughSubject<EnterLoadingViewModel.Input, Never>()
    
    public init(
        viewModel: EnterLoadingViewModel,
        waitingRoomViewController: WaitingRoomViewController
    ) {
        self.viewModel = viewModel
        self.waitingRoomViewController = waitingRoomViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        setupConstraints()
        configureUI()
        bindOutput()
        activityIndicator.startAnimating()
        input.send(.viewDidLoad)
    }
    
    public func addViews() {
        view.addSubview(label)
        view.addSubview(activityIndicator)
    }
    
    public func setupConstraints() {
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(activityIndicator.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    public func configureUI() {
        view.backgroundColor = PTGColor.gray90.color
        label.text = "방에 입장 중입니다..."
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        label.setKern()
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] in
            guard let self else { return }
            switch $0 {
            case .navigateToWaitingRoom(let isGuest):
                self.modalPresentationStyle = .fullScreen
                self.present(waitingRoomViewController, animated: false)
            }
        }
        .store(in: &cancellables)
    }
}
