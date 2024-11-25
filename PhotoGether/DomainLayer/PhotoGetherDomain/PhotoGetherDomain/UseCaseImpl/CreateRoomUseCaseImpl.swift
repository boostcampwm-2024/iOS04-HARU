import Foundation
import PhotoGetherDomainInterface

public final class CreateRoomUseCaseImpl: CreateRoomUseCase {
    public func execute() -> Bool {
        repository.roomService.createRoom()
    }
    
    private let repository: ConnectionRepository
    
    public init(repository: ConnectionRepository) {
        self.repository = repository
    }
}
