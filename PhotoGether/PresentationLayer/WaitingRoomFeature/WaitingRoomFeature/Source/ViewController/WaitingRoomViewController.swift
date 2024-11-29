import UIKit
import Combine
import BaseFeature
import PhotoRoomFeature
import DesignSystem
import PhotoGetherDomainInterface

public final class WaitingRoomViewController: BaseViewController {
    private let viewModel: WaitingRoomViewModel
    private let waitingRoomView = WaitingRoomView()
    private let participantsCollectionViewController = ParticipantsCollectionViewController()
    private let photoRoomViewController: PhotoRoomViewController
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    
    private let input = PassthroughSubject<WaitingRoomViewModel.Input, Never>()
    
    public init(
        viewModel: WaitingRoomViewModel,
        photoRoomViewController: PhotoRoomViewController
    ) {
        self.viewModel = viewModel
        self.photoRoomViewController = photoRoomViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = waitingRoomView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        defer { viewDidLoadSubject.send(()) }
        addViews()
        setupConstraints()
        configureUI()
        bindInput()
        bindOutput()
        setPlaceHolder()
    }
    
    private func addViews() {
        addChild(participantsCollectionViewController)
        participantsCollectionViewController.didMove(toParent: self)
        
        let collectionView = participantsCollectionViewController.view ?? UIView()
        let micButton = waitingRoomView.micButton
        waitingRoomView.insertSubview(collectionView, belowSubview: micButton)
    }
    
    private func setupConstraints() {
        let collectionView = participantsCollectionViewController.view ?? UIView()
        let topOffset: CGFloat = APP_HEIGHT() > 667 ? 44 : 0 // 최소사이즈 기기 SE2 기준
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(topOffset)
            $0.bottom.equalTo(waitingRoomView.bottomBarView.snp.top)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    private func configureUI() {
        participantsCollectionViewController.collectionView.backgroundColor = PTGColor.gray90.color
    }

    private func bindInput() {
        viewDidLoadSubject.sink { [weak self] _ in
            self?.input.send(.viewDidLoad)
        }.store(in: &cancellables)
        
        waitingRoomView.micButton.tapPublisher
            .sink { [weak self] _ in
                self?.input.send(.micMuteButtonDidTap)
            }.store(in: &cancellables)
        
        waitingRoomView.linkButton.tapPublisher
            .sink { [weak self] _ in
                self?.input.send(.linkButtonDidTap)
            }.store(in: &cancellables)
        
        waitingRoomView.startButton.tapPublisher
            .throttle(for: .seconds(1), scheduler: RunLoop.main, latest: false)
            .sink { [weak self] _ in
                self?.input.send(.startButtonDidTap)
            }.store(in: &cancellables)
    }
    
    private func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] in
            guard let self else { return }
            switch $0 {
                
            // MARK: 네비게이션 처리
            case .navigateToPhotoRoom:
                self.navigateToPhotoRoom()
                
            // MARK: 내 비디오 화면 업데이트
            case .localVideo(let localVideoView):
                self.updateParticipantView(
                    position: .host,
                    nickname: "나는 호스트",
                    videoView: localVideoView
                )
                
            // MARK: 상대방 비디오 화면 업데이트
            case .remoteVideos(let remoteVideoViews):
                guard let remoteVideoView = remoteVideoViews.first else { return }
                self.updateParticipantView(
                    position: .guest3,
                    nickname: "나는 게스트",
                    videoView: remoteVideoView
                )
            // MARK: 마이크 음소거 UI 업데이트
            case .micMuteState:
                return
                
            // MARK: 초대를 위한 공유시트 present
            case .shouldShowShareSheet(let urlScheme):
                self.showShareSheet(message: urlScheme)

            // MARK: 토스트 메시지 노출
            case .shouldShowToast(let message):
                self.showToast(message: message, duration: 3.0)
            }
        }.store(in: &cancellables)
    }

    private func navigateToPhotoRoom() {
        let collectionVC = participantsCollectionViewController
        let photoRoomVC = photoRoomViewController
        photoRoomVC.setCollectionViewController(collectionVC)
        navigationController?.pushViewController(photoRoomVC, animated: true)
    }

    private func updateParticipantView(
        position: ParticipantsSectionItem.Position,
        nickname: String,
        videoView: UIView
    ) {
        var snapshot = participantsCollectionViewController.dataSource.snapshot()
        var items = snapshot.itemIdentifiers
        
        guard let index = items.firstIndex(where: { $0.position == position }) else { return }
        
        let newItem = SectionItem(position: position, nickname: nickname, videoView: videoView)
        
        items.remove(at: index)
        items.insert(newItem, at: index)
        
        snapshot.deleteItems(items)
        snapshot.appendItems(items, toSection: 0)
        
        participantsCollectionViewController.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setPlaceHolder() {
        let placeHolder = [
            ParticipantsSectionItem(position: .host, nickname: "host"),
            ParticipantsSectionItem(position: .guest1, nickname: "guest1"),
            ParticipantsSectionItem(position: .guest2, nickname: "guest2"),
            ParticipantsSectionItem(position: .guest3, nickname: "guest3")
        ]
        var snapshot = participantsCollectionViewController.dataSource.snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(placeHolder, toSection: 0)
        participantsCollectionViewController.dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func showShareSheet(message: String) {
        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }
}
