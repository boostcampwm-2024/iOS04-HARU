import Foundation
import Combine

public protocol CreateRoomUseCase {
    func execute() -> AnyPublisher<String, any Error>
}
