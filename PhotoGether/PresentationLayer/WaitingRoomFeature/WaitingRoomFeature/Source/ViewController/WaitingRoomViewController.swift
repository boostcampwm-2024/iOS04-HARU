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
        addViews()
        setupConstraints()
        configureUI()
        setActions()
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
    
    private func setActions() {
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
