import Combine

public protocol JoinRoomUseCase {
    func execute() -> AnyPublisher<Bool, Never>
}
