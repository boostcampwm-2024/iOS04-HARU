import UIKit
import Combine
import BaseFeature
import PhotoRoomFeature
import DesignSystem
import PhotoGetherDomainInterface

public final class WaitingRoomViewController: BaseViewController {
    private let viewModel: WaitingRoomViewModel
    private let waitingRoomView = WaitingRoomView()
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
        bindInput()
        bindOutput()
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
                print(localVideoView)
                self.waitingRoomView.updateParticipantView(view: localVideoView, position: .topLeading)
                
            // MARK: 상대방 비디오 화면 업데이트
            case .remoteVideos(let remoteVideoViews):
                let guest1 = remoteVideoViews[safe: 0] ?? UIView()
                let guest2 = remoteVideoViews[safe: 1] ?? UIView()
                let guest3 = remoteVideoViews[safe: 2] ?? UIView()
                
                self.waitingRoomView.updateParticipantView(view: guest1, position: .topTrailing)
                self.waitingRoomView.updateParticipantView(view: guest2, position: .bottomLeading)
                self.waitingRoomView.updateParticipantView(view: guest3, position: .bottomTrailing)

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
    
    private func showShareSheet(message: String) {
        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }
}
