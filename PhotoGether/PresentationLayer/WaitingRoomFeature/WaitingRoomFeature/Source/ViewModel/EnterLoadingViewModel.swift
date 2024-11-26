import UIKit
import Combine
import PhotoGetherDomainInterface

public final class EnterLoadingViewModel {
    private var cancellables = Set<AnyCancellable>()
    
    public enum Input {
        case viewDidLoad
    }
    
    public enum Output {
        case navigateToWaitingRoom(isGuest: Bool)
    }
    
    private let _output = PassthroughSubject<Output, Never>()
    public var output: AnyPublisher<Output, Never> { _output.eraseToAnyPublisher() }
    
    private let joinRoomUseCase: JoinRoomUseCase
    
    public init(joinRoomUseCase: JoinRoomUseCase) {
        self.joinRoomUseCase = joinRoomUseCase
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] in
            guard let self else { return }
            
            switch $0 {
            case .viewDidLoad:
                self.requestJoinRoom()
            }
        }.store(in: &cancellables)
        
        return output
    }
    
    private func requestJoinRoom() {
        joinRoomUseCase.execute()
            .sink { [weak self] isGuest in
                self?._output.send(.navigateToWaitingRoom(isGuest: isGuest))
            }
            .store(in: &cancellables)
    }
}
