import UIKit
import Combine
import PhotoGetherDomainInterface
import CoreModule

public final class WaitingRoomViewModel {
    enum Input {
        case viewDidLoad
        case micMuteButtonDidTap
        case linkButtonDidTap
        case startButtonDidTap
    }
    
    enum Output {
        case shouldUpdateVideoView(UIView, Int)
        case shouldUpdateNickname(String, Int)
        case micMuteState(Bool)
        case shouldShowShareSheet(String)
        case navigateToPhotoRoom
        case shouldShowToast(String)
    }
    
    private let sendOfferUseCase: SendOfferUseCase
    private let getLocalVideoUseCase: GetLocalVideoUseCase
    private let getRemoteVideoUseCase: GetRemoteVideoUseCase
    private let createRoomUseCase: CreateRoomUseCase
    private let didEnterNewUserPublisherUseCase: DidEnterNewUserPublisherUseCase
    private let changeLocalMicStateUseCase: ChangeLocalMicStateUseCase
    
    private var isHost: Bool
    private var cancellables = Set<AnyCancellable>()
    private let output = PassthroughSubject<Output, Never>()
    
    public init(
        isHost: Bool,
        sendOfferUseCase: SendOfferUseCase,
        getLocalVideoUseCase: GetLocalVideoUseCase,
        getRemoteVideoUseCase: GetRemoteVideoUseCase,
        createRoomUseCase: CreateRoomUseCase,
        didEnterNewUserPublisherUseCase: DidEnterNewUserPublisherUseCase,
        changeLocalMicStateUseCase: ChangeLocalMicStateUseCase
    ) {
        self.isHost = isHost
        self.sendOfferUseCase = sendOfferUseCase
        self.getLocalVideoUseCase = getLocalVideoUseCase
        self.getRemoteVideoUseCase = getRemoteVideoUseCase
        self.createRoomUseCase = createRoomUseCase
        self.didEnterNewUserPublisherUseCase = didEnterNewUserPublisherUseCase
        self.changeLocalMicStateUseCase = changeLocalMicStateUseCase
        
        bindSideEffects()
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            self?.handleEvent(event)
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func bindSideEffects() {
        didEnterNewUserPublisherUseCase.publisher().sink { [weak self] userInfo, newUserVideoView in
            guard let self else { return }
            self.output.send(.shouldUpdateVideoView(newUserVideoView, userInfo.viewPosition.rawValue))
            self.output.send(.shouldUpdateNickname(userInfo.nickname, userInfo.viewPosition.rawValue))
            let message = "\(userInfo.nickname)님이 참가했어요."
            self.output.send(.shouldShowToast(message))
        }.store(in: &cancellables)
    }
    
    private func handleEvent(_ event: Input) {
        switch event {
        case .viewDidLoad:
            handleViewDidLoad()
        case .micMuteButtonDidTap:
            handleMicButtonDidTap()
        case .linkButtonDidTap:
            handleLinkButtonDidTap()
        case .startButtonDidTap:
            if isHost {
                output.send(.navigateToPhotoRoom)
            }
        }
    }
    
    private func handleViewDidLoad() {
        updateVideoViewAndNickname()
        if !isHost {
            sendOffer()
        }
    }
    
    private func updateVideoViewAndNickname() {
        if isHost {
            let localVideoView = getLocalVideoUseCase.execute().1
            output.send(.shouldUpdateVideoView(localVideoView, 0))
        } else {
            let (userInfo, localVideoView) = getLocalVideoUseCase.execute()
            if let userInfo {
                output.send(.shouldUpdateVideoView(localVideoView, userInfo.viewPosition.rawValue))
                output.send(.shouldUpdateNickname(userInfo.nickname, userInfo.viewPosition.rawValue))
            }
            
            let remoteUpdateCancellable = getRemoteVideoUseCase.execute()
                .publisher
                .compactMap { ($0.0, $0.1) }
                .sink { [weak self] userInfo, remoteVideoView in
                    guard let self, let userInfo else { return }
                    self.output.send(.shouldUpdateVideoView(remoteVideoView, userInfo.viewPosition.rawValue))
                    self.output.send(.shouldUpdateNickname(userInfo.nickname, userInfo.viewPosition.rawValue))
                }
            remoteUpdateCancellable.cancel()
        }
    }
    
    private func sendOffer() {
        let cancellable = sendOfferUseCase.execute().sink { [weak self] completion in
            switch completion {
            case .finished:
                return
            case .failure(let error):
                self?.output.send(.shouldShowToast("연결 중 에러가 발생했어요."))
                PTGLogger.default.log(error.localizedDescription)
            }
        } receiveValue: { [weak self] _ in
            self?.output.send(.shouldShowToast("연결을 시도합니다."))
        }
        cancellable.cancel()
    }
    
    private func handleLinkButtonDidTap() {
        createRoomUseCase.execute()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    debugPrint(error.localizedDescription)
                    self?.output.send(.shouldShowToast("Failed to create room"))
                }
            }, receiveValue: { [weak self] roomLink in
                self?.output.send(.shouldShowShareSheet(roomLink))
            })
            .store(in: &cancellables)
    }
    
    private func handleMicButtonDidTap() {
        changeLocalMicStateUseCase.execute()
            .sink { [weak self] state in
                self?.output.send(.micMuteState(state))
            }.store(in: &cancellables)
    }
}
