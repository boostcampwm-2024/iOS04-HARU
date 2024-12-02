import Combine

public protocol ToggleLocalMicStateUseCase {
    func execute() -> AnyPublisher<Bool, Never>
}
