import Foundation
import Combine
import PhotoGetherDomainInterface

public final class JoinRoomUseCaseImpl: JoinRoomUseCase {
    // TODO: 수정 필요
    public func execute() -> AnyPublisher<Bool, Never> {
        return Just(true)
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
