import Combine

public protocol JoinRoomUseCase {
    func execute(roomID: String, hostID: String) -> AnyPublisher<Bool, Never>
}
