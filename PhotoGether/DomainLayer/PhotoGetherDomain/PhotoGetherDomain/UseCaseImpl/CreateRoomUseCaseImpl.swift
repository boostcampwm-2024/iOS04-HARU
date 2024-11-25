import Foundation
import Combine
import PhotoGetherDomainInterface

public final class CreateRoomUseCaseImpl: CreateRoomUseCase {
    public func execute() -> AnyPublisher<CreateRoomEntity, any Error> {
        connectionRepository.roomService.createRoom()
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
