import UIKit
import Combine
import PhotoGetherDomainInterface

public final class WaitingRoomViewModel {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let micMuteButtonDidTap: AnyPublisher<Void, Never>
        let linkButtonDidTap: AnyPublisher<Void, Never>
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
    
    private var isGuest: Bool = false
    private let sendOfferUseCase: SendOfferUseCase
    private let getLocalVideoUseCase: GetLocalVideoUseCase
    private let getRemoteVideoUseCase: GetRemoteVideoUseCase
    private let createRoomUseCase: CreateRoomUseCase
    
    public init(
        sendOfferUseCase: SendOfferUseCase,
        getLocalVideoUseCase: GetLocalVideoUseCase,
        getRemoteVideoUseCase: GetRemoteVideoUseCase,
        createRoomUseCase: CreateRoomUseCase
    ) {
        self.sendOfferUseCase = sendOfferUseCase
        self.getLocalVideoUseCase = getLocalVideoUseCase
        self.getRemoteVideoUseCase = getRemoteVideoUseCase
        self.createRoomUseCase = createRoomUseCase
    }
    
    func transform(input: Input) -> Output {
        let newMicMuteState = mutateMicMuteButtonDidTap(input)
        let newShouldShowShareSheet = mutateLinkButtonDidTap(input)
        let newNavigateToPhotoRoom = mutateStartButtonDidTap(input)
        let sendOfferOnGuestTestPublisher = Publishers.MergeMany([
            newShouldShowShareSheet, sendOfferOnGuestTest(input)
        ]).eraseToAnyPublisher()
        
        let output = Output(
            localVideo: bindLocalVideo(input),
            remoteVideos: bindRemoteVideos(input),
            micMuteState: newMicMuteState,
            shouldShowShareSheet: newShouldShowShareSheet,
            navigateToPhotoRoom: newNavigateToPhotoRoom,
            shouldShowToast: sendOfferOnGuestTestPublisher
        )
        return output
    }

    
    public func setGuestMode(_ isGuest: Bool) {
        self.isGuest = isGuest
    }
}

private extension WaitingRoomViewModel {
    func sendOfferOnGuestTest(_ input: Input) -> AnyPublisher<String, Never> {
        input.viewDidLoad.map { [weak self] _ in
            guard let self else { return "" }
            let result = self.sendOfferUseCase.execute()
            return result ? "Offer sent" : "Error sending offer"
        }.eraseToAnyPublisher()
    }
    
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
    
    func mutateLinkButtonDidTap(_ input: Input) -> AnyPublisher<String, Never> {
        input.linkButtonDidTap
            .flatMap { [weak self] _ -> AnyPublisher<String, Never> in
                guard let self else { return Just("").eraseToAnyPublisher() }
                return self.createRoomUseCase.execute()
                    .catch { error in
                        debugPrint(error.localizedDescription)
                        return Just("").eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func mutateStartButtonDidTap(_ input: Input) -> AnyPublisher<Void, Never> {
        return input.startButtonDidTap.eraseToAnyPublisher()
    }
}

public enum WaitingRoomViewModelError: LocalizedError {
    case selfIsNil
    
    public var errorDescription: String? {
        switch self {
        case .selfIsNil: "WaitingRoomViewModel is nil"
        }
    }
}
