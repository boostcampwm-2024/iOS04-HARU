import UIKit
import Combine
import PhotoGetherDomainInterface

public final class PhotoRoomViewModel {
    private var cancellables = Set<AnyCancellable>()
    private var timerCount: Int = 3
    
    enum Input {
        case cameraButtonTapped
    }
    
    enum Output {
        case timer(count: Int)
        case timerCompleted(images: [UIImage])
    }
    
    private var output = PassthroughSubject<Output, Never>()
    
    private let captureVideosUseCase: CaptureVideosUseCase
    private let stopVideoCaptureUseCase: StopVideoCaptureUseCase
    
    public init(
        captureVideosUseCase: CaptureVideosUseCase,
        stopVideoCaptureUseCase: StopVideoCaptureUseCase
    ) {
        self.captureVideosUseCase = captureVideosUseCase
        self.stopVideoCaptureUseCase = stopVideoCaptureUseCase
    }
    
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
                
                let images = self.captureVideosUseCase.execute()
                let result = Output.timerCompleted(images: images)
                self.stopVideoCaptureUseCase.execute()
                
                self.output.send(result)
                timer.invalidate()
            }
        }
    }
}
