import UIKit
import Combine
import BaseFeature
import PhotoRoomFeature
import DesignSystem
import PhotoGetherDomainInterface

public final class WaitingRoomViewController: BaseViewController, ViewControllerConfigure {
    private let viewModel: WaitingRoomViewModel
    private let waitingRoomView = WaitingRoomView()
    private let participantsCollectionViewController = ParticipantsCollectionViewController()
    private let photoRoomViewController: PhotoRoomViewController
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    
    public init(
        viewModel: WaitingRoomViewModel,
        photoRoomViewController: PhotoRoomViewController
    ) {
        self.viewModel = viewModel
        self.photoRoomViewController = photoRoomViewController
        super.init(nibName: nil, bundle: nil)
    }
    
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
        bindOutput()
        setPlaceHolder()
        bindNoti()
    }
    
    private func bindNoti() {
        NotificationCenter.default.publisher(for: .navigateToPhotoRoom).sink { [weak self] noti in
            guard let self else { return }
            let collectionVC = participantsCollectionViewController
            let photoRoomVC = self.photoRoomViewController
            photoRoomVC.setCollectionViewController(collectionVC)
            self.navigationController?.pushViewController(photoRoomVC, animated: true)
        }.store(in: &cancellables)
    }
    
    public func addViews() {
        addChild(participantsCollectionViewController)
        participantsCollectionViewController.didMove(toParent: self)
        
        let collectionView = participantsCollectionViewController.view!
        let micButton = waitingRoomView.micButton
        waitingRoomView.insertSubview(collectionView, belowSubview: micButton)
       
    }
    
    public func setupConstraints() {
        let collectionView = participantsCollectionViewController.view!
        let topOffset: CGFloat = APP_HEIGHT() > 667 ? 44 : 0 // 최소사이즈 기기 SE2 기준
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(topOffset)
            $0.bottom.equalTo(waitingRoomView.bottomBarView.snp.top)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    public func configureUI() {
        participantsCollectionViewController.collectionView.backgroundColor = PTGColor.gray90.color
    }
    
    private func createInput() -> WaitingRoomViewModel.Input {
        let viewDidLoadPublisher = viewDidLoadSubject.eraseToAnyPublisher()
        let startButtonTapPublisher = waitingRoomView.startButton.tapPublisher
            .throttle(for: .seconds(1), scheduler: RunLoop.main, latest: false)
            .eraseToAnyPublisher()
        
        waitingRoomView.linkButton.tapPublisher.sink { [weak self] _ in
            print("linkButton did tap")
            self?.viewModel.sendOffer()
        }.store(in: &cancellables)
        
        return WaitingRoomViewModel.Input(
            viewDidLoad: viewDidLoadPublisher,
            micMuteButtonDidTap: waitingRoomView.micButton.tapPublisher,
            linkButtonDidTap: waitingRoomView.linkButton.tapPublisher,
            startButtonDidTap: startButtonTapPublisher
        )
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: createInput())
        
        output.navigateToPhotoRoom.sink { [weak self] _ in
            guard let self else { return }
            
            let collectionVC = participantsCollectionViewController
            let photoRoomVC = self.photoRoomViewController
            photoRoomVC.setCollectionViewController(collectionVC)
            NotificationCenter.default.post(name: .navigateToPhotoRoom, object: nil)
            self.navigationController?.pushViewController(photoRoomVC, animated: true)
        }.store(in: &cancellables)
        
        output.localVideo.sink { [weak self] localVideoView in
            guard let self else { return }
            
            var snapshot = self.participantsCollectionViewController.dataSource.snapshot()
            var items = snapshot.itemIdentifiers
            guard let hostIndex = items.firstIndex(where: { $0.position == .host }) else { return }
            
            let newItem = SectionItem(position: .host, nickname: "나는 호스트", videoView: localVideoView)

            items.remove(at: hostIndex)
            items.insert(newItem, at: hostIndex)
            
            snapshot.deleteItems(items)
            snapshot.appendItems(items, toSection: 0)

            self.participantsCollectionViewController.dataSource.apply(snapshot, animatingDifferences: true)

        }.store(in: &cancellables)
        
        output.remoteVideos.sink { [weak self] remoteVideoViews in
            guard let self else { return }
            guard let remoteVideoView = remoteVideoViews.first else { return }
            
            var snapshot = self.participantsCollectionViewController.dataSource.snapshot()
            var items = snapshot.itemIdentifiers
            guard let guestIndex = items.firstIndex(where: { $0.position == .guest3 }) else { return }
            
            let newItem = SectionItem(position: .guest3, nickname: "나는 게스트", videoView: remoteVideoView)

            items.remove(at: guestIndex)
            items.insert(newItem, at: guestIndex)
            
            snapshot.deleteItems(items)
            snapshot.appendItems(items, toSection: 0)

            self.participantsCollectionViewController.dataSource.apply(snapshot, animatingDifferences: true)
        }.store(in: &cancellables)
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
