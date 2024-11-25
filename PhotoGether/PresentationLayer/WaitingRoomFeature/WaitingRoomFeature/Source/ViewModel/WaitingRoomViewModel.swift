import UIKit
import Combine
import PhotoGetherDomainInterface

public final class WaitingRoomViewModel {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let micMuteButtonDidTap: AnyPublisher<Void, Never>
        let shareButtonDidTap: AnyPublisher<Void, Never>
        let startButtonDidTap: AnyPublisher<Void, Never>
    }

    struct Output {
        let localVideo: AnyPublisher<UIView, Never>
        let remoteVideos: AnyPublisher<[UIView], Never>
        let micMuteState: AnyPublisher<Bool, Never>
        let shouldShowShareSheet: AnyPublisher<String, Never>
        let navigateToPhotoRoom: AnyPublisher<Void, Never>
        let shouldShowToast: AnyPublisher<String, Never>
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private let sendOfferUseCase: SendOfferUseCase
    private let getLocalVideoUseCase: GetLocalVideoUseCase
    private let getRemoteVideoUseCase: GetRemoteVideoUseCase
    
    public init(
        sendOfferUseCase: SendOfferUseCase,
        getLocalVideoUseCase: GetLocalVideoUseCase,
        getRemoteVideoUseCase: GetRemoteVideoUseCase
    ) {
        self.sendOfferUseCase = sendOfferUseCase
        self.getLocalVideoUseCase = getLocalVideoUseCase
        self.getRemoteVideoUseCase = getRemoteVideoUseCase
    }
    
    func transform(input: Input) -> Output {
        let newMicMuteState = mutateMicMuteButtonDidTap(input)
        let newShouldShowShareSheet = mutateShareButtonDidTap(input)
        let newNavigateToPhotoRoom = mutateStartButtonDidTap(input)
        
        let output = Output(
            localVideo: bindLocalVideo(input),
            remoteVideos: bindRemoteVideos(input),
            micMuteState: newMicMuteState,
            shouldShowShareSheet: newShouldShowShareSheet,
            navigateToPhotoRoom: newNavigateToPhotoRoom,
            shouldShowToast: newShouldShowShareSheet
        )
        
        return output
    }
    
    func sendOffer() {
        sendOfferUseCase.execute()
    }
}

private extension WaitingRoomViewModel {
    func bindLocalVideo(_ input: Input) -> AnyPublisher<UIView, Never> {
        input.viewDidLoad.map { [weak self] _ in
            guard let self else { return UIView() }
            return self.getLocalVideoUseCase.execute()
        }.eraseToAnyPublisher()
    }
    
    func bindRemoteVideos(_ input: Input) -> AnyPublisher<[UIView], Never> {
        input.viewDidLoad.map { [weak self] _ in
            guard let self else { return [] }
            return self.getRemoteVideoUseCase.execute()
        }.eraseToAnyPublisher()
    }
    
    func mutateMicMuteButtonDidTap(_ input: Input) -> AnyPublisher<Bool, Never> {
        input.micMuteButtonDidTap.map { _ -> Bool in
            return true
        }.eraseToAnyPublisher()
    }
    
    func mutateShareButtonDidTap(_ input: Input) -> AnyPublisher<String, Never> {
        input.shareButtonDidTap.map { [weak self] _ -> String in
            guard let self else { return "레전드 에러 발생" }
            self.sendOfferUseCase.execute()
            return "연결을 시도합니다."
        }
        .eraseToAnyPublisher()
    }
    
    func mutateStartButtonDidTap(_ input: Input) -> AnyPublisher<Void, Never> {
        return input.startButtonDidTap.eraseToAnyPublisher()
    }
}
