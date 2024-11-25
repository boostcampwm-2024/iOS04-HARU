import Foundation
import Combine

public protocol CreateRoomUseCase {
    func execute() -> AnyPublisher<CreateRoomEntity, any Error>
}
