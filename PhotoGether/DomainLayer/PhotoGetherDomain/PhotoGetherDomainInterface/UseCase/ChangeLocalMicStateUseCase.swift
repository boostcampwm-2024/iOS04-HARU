import Combine

public protocol ChangeLocalMicStateUseCase {
    func execute() -> AnyPublisher<Bool, Never>
}
