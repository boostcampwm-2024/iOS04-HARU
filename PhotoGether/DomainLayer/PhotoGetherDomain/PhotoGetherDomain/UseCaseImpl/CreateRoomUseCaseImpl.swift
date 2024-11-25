import Foundation
import PhotoGetherDomainInterface

public final class CreateRoomUseCaseImpl: CreateRoomUseCase {
    @discardableResult
    public func execute() -> Bool {
        connectionRepository.roomService.createRoom()
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
