import Combine
import PhotoGetherDomainInterface

public final class ToggleLocalMicStateUseCaseImpl: ToggleLocalMicStateUseCase {
    public func execute() -> AnyPublisher<Bool, Never> {
        connectionRepository.switchLocalAudioTrackState()
        return connectionRepository.didChangeLocalAudioTrackStatePublisher
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
