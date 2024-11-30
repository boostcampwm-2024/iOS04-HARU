import Foundation
import Combine
import PhotoGetherDomainInterface

public final class JoinRoomUseCaseImpl: JoinRoomUseCase {
    public func execute(roomID: String, hostID: String) -> AnyPublisher<Bool, Never> {
        return connectionRepository.joinRoom(to: roomID, hostID: hostID)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
