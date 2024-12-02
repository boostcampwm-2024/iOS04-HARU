import Combine

public protocol ChangeLcoalMicStateUseCase {
    func execute() -> AnyPublisher<Bool, Never>
}
