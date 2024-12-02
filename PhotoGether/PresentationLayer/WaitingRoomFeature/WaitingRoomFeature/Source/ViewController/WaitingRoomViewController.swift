import UIKit
import Combine
import BaseFeature
import PhotoRoomFeature
import DesignSystem
import PhotoGetherDomainInterface
import CoreModule

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
        navigationController?.setNavigationBarHidden(true, animated: false)
        bindInput()
        bindOutput()
        bindNoti()
    }
    
    private func bindNoti() {
        NotificationCenter.default.publisher(for: .receiveNavigateToPhotoRoom)
            .receive(on: RunLoop.main)
            .first()
            .sink { [weak self] _ in
                print("DEBUG: 노티 받음")
            guard let self else { return }
            let photoRoomVC = self.photoRoomViewController
                photoRoomVC.setParticipantsGridView(waitingRoomView.particiapntsGridView)
                
            self.navigationController?.pushViewController(photoRoomVC, animated: true)
        }.store(in: &cancellables)
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
        
        output
            .receive(on: RunLoop.main)
            .sink { [weak self] in
            guard let self else { return }
            switch $0 {
            // MARK: 네비게이션 처리
            case .navigateToPhotoRoom:
                self.navigateToPhotoRoom()
                
            // MARK: 화면 업데이트
            case let .shouldUpdateVideoView(videoView, viewPosition):
                guard let participantPosition = ParticipantPosition(rawValue: viewPosition) else { return }
                updateParticipantView(view: videoView, position: participantPosition)
            
            // MARK: 닉네임 업데이트
            case let .shouldUpdateNickname(nickname, viewPosition):
                guard let participantPosition = ParticipantPosition(rawValue: viewPosition) else { return }
                updateParticipantNickname(nickname: nickname, position: participantPosition)
            
            // MARK: 마이크 음소거 UI 업데이트
            case .micMuteState(let isOn):
                waitingRoomView.changeMicButtonState(isOn: isOn)
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

    private func updateParticipantView(view: UIView, position: ParticipantPosition) {
        self.waitingRoomView.particiapntsGridView.updateParticipantView(view: view, position: position)
    }
    
    private func updateParticipantNickname(nickname: String, position: ParticipantPosition) {
        self.waitingRoomView.particiapntsGridView.updateParticipantNickname(nickName: nickname, position: position)
    }
    
    // MARK: 현재 뷰의 하이어라키에선 particiapntsGridView가 사라짐
    private func navigateToPhotoRoom() {
        NotificationCenter.default.post(name: .navigateToPhotoRoom, object: nil)
        
        let photoRoomVC = self.photoRoomViewController
            photoRoomVC.setParticipantsGridView(waitingRoomView.particiapntsGridView)
            
        self.navigationController?.pushViewController(photoRoomVC, animated: true)
    }
    
    private func showShareSheet(message: String) {
        let activityViewController = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }
}
