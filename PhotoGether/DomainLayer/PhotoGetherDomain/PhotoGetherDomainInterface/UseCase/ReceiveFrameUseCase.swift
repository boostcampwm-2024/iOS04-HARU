import Combine

public protocol ReceiveFrameUseCase {
    func execute() -> AnyPublisher<FrameEntity, Never>
}
