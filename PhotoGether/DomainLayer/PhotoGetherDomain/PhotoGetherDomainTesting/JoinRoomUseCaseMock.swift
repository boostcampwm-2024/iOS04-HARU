import Foundation
import Combine
import PhotoGetherDomainInterface

public final class JoinRoomUseCaseMock: JoinRoomUseCase {
    public func execute() -> AnyPublisher<Bool, Never> {
        return Just(true)
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
