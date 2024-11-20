import Combine
import Foundation

final class PhotoRoomViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var timerCount: Int = 3
    
    enum Input {
        case cameraButtonTapped
    }
    
    enum Output {
        case timer(count: Int)
        case timerCompleted
    }
    
    private var output = PassthroughSubject<Output, Never>()
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] in
            guard let self else { return }
            
            switch $0 {
            case .cameraButtonTapped:
                self.startTimer()
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func startTimer() {
        output.send(.timer(count: timerCount))
        
        let _ = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] timer in
            guard let self else { return }
            
            self.timerCount -= 1
            self.output.send(.timer(count: self.timerCount))
            
            if self.timerCount == 0 {
                self.timerCount = 3
                self.output.send(.timerCompleted)
                timer.invalidate()
            }
        }
    }
}
