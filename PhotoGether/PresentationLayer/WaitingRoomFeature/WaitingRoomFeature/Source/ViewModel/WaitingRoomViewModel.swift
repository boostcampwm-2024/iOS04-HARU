import Foundation
import Combine
import PhotoGetherDomainInterface

public final class WaitingRoomViewModel {
    struct Input {
        let micMuteButtonDidTap: AnyPublisher<Void, Never>
        let shareButtonDidTap: AnyPublisher<Void, Never>
        let startButtonDidTap: AnyPublisher<Void, Never>
    }

    struct Output {
        let micMuteState: AnyPublisher<Bool, Never>
        let shouldShowShareSheet: AnyPublisher<String, Never>
        let navigateToPhotoRoom: AnyPublisher<Void, Never>
    }
    
    private var cancellables = Set<AnyCancellable>()
    let connectionClient: ConnectionClient
    
    public init(connectionClient: ConnectionClient) {
        self.connectionClient = connectionClient
    }
    
    func transform(input: Input) -> Output {
        let newMicMuteState = mutateMicMuteButtonDidTap(input)
        let newShouldShowShareSheet = mutateShareButtonDidTap(input)
        let newNavigateToPhotoRoom = mutateStartButtonDidTap(input)
        
        let output = Output(
            micMuteState: newMicMuteState,
            shouldShowShareSheet: newShouldShowShareSheet,
            navigateToPhotoRoom: newNavigateToPhotoRoom
        )
        
        return output
    }
}

private extension WaitingRoomViewModel {
    func mutateMicMuteButtonDidTap(_ input: Input) -> AnyPublisher<Bool, Never> {
        input.micMuteButtonDidTap.map { _ -> Bool in
            return true
        }.eraseToAnyPublisher()
    }
    
    func mutateShareButtonDidTap(_ input: Input) -> AnyPublisher<String, Never> {
        return Just("ROOMID1234").eraseToAnyPublisher()
    }
    
    func mutateStartButtonDidTap(_ input: Input) -> AnyPublisher<Void, Never> {
        return Just(()).eraseToAnyPublisher()
    }
}
