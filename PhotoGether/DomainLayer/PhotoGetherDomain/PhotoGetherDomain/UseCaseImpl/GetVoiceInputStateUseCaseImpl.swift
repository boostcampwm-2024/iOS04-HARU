import PhotoGetherDomainInterface

public final class GetVoiceInputStateUseCaseImpl: GetVoiceInputStateUseCase {
    public func execute() -> Bool {
        return connectionRepository.currentLocalVideoInputState
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
