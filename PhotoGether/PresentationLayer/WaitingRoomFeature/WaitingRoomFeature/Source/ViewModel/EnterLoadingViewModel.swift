import UIKit
import Combine
import PhotoGetherDomainInterface

public final class EnterLoadingViewModel {
    private var cancellables = Set<AnyCancellable>()
    
    public enum Input {
        case viewDidLoad
    }
    
    public enum Output {
        case didJoinRoom(isSuccess: Bool)
    }
    
    private let _output = PassthroughSubject<Output, Never>()
    public var output: AnyPublisher<Output, Never> { _output.eraseToAnyPublisher() }
    
    private let joinRoomUseCase: JoinRoomUseCase
    private let roomID: String
    private let hostID: String
    
    public init(joinRoomUseCase: JoinRoomUseCase, roomID: String, hostID: String) {
        self.joinRoomUseCase = joinRoomUseCase
        self.roomID = roomID
        self.hostID = hostID
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] in
            guard let self else { return }
            
            switch $0 {
            case .viewDidLoad:
                self.requestJoinRoom(roomID: self.roomID, hostID: self.hostID)
            }
        }.store(in: &cancellables)
        
        return output
    }
    
    private func requestJoinRoom(roomID: String, hostID: String) {
        joinRoomUseCase.execute(roomID: roomID, hostID: hostID)
            .sink { [weak self] isSuccess in
                self?._output.send(.didJoinRoom(isSuccess: isSuccess))
            }
            .store(in: &cancellables)
    }
}
