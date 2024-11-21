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
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    
    public init(viewModel: WaitingRoomViewModel) {
        self.viewModel = viewModel
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
        setDummy()
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
        
        return WaitingRoomViewModel.Input(
            viewDidLoad: viewDidLoadPublisher,
            micMuteButtonDidTap: waitingRoomView.micButton.tapPublisher,
            shareButtonDidTap: waitingRoomView.shareButton.tapPublisher,
            startButtonDidTap: startButtonTapPublisher
        )
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: createInput())
        
        output.navigateToPhotoRoom.sink { _ in
            print("navigateToPhotoRoom 버튼이 눌렸어요!")
        }.store(in: &cancellables)
        
        output.localVideo.sink { [weak self] localVideoView in
            guard let self else { return }
            var snapshot = self.participantsCollectionViewController.dataSource.snapshot()
            guard var item = snapshot.itemIdentifiers[safe: 0] else { return }
            item.setNickname("나야, 호스트")
            item.setVideoView(localVideoView)
            snapshot.reconfigureItems([item])
        }.store(in: &cancellables)
        
        output.remoteVideos.sink { [weak self] remoteVideoView in
            guard let self else { return }
            var snapshot = self.participantsCollectionViewController.dataSource.snapshot()
            guard var item = snapshot.itemIdentifiers[safe: 2] else { return }
            guard let firstRemoteView = remoteVideoView.first else {
                print("으엥?!?")
                return
            }
            item.setNickname("나는야 게스트")
            item.setVideoView(firstRemoteView)
            snapshot.reconfigureItems([item])
        }.store(in: &cancellables)
        
        output.shouldShowToast.sink { [weak self] message in
            print(message)
        }.store(in: &cancellables)
    }
    
    private func setDummy() {
        let dummyData = [
            ParticipantsSectionItem(videoID: 0, nickname: "h"),
            ParticipantsSectionItem(videoID: 0, nickname: ""),
            ParticipantsSectionItem(videoID: 0, nickname: "guest322"),
            ParticipantsSectionItem(videoID: 0, nickname: "guest444232328787873")
        ]
        var snapshot = participantsCollectionViewController.dataSource.snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(dummyData, toSection: 0)
        participantsCollectionViewController.dataSource.apply(snapshot, animatingDifferences: true)
    }
}
