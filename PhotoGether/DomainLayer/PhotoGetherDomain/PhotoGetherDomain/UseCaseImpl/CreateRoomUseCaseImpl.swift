import Foundation
import PhotoGetherDomainInterface

public final class CreateRoomUseCaseImpl: CreateRoomUseCase {
    public func execute() -> Result<(roomID: String, userID: String), Error> {
        repository.
    }
    
    private let repository: ConnectionRepository
    
    public init(repository: ConnectionRepository) {
        self.repository = repository
    }
}
