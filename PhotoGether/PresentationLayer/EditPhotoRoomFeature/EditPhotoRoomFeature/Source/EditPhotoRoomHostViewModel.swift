import Foundation
import Combine

public final class EditPhotoRoomHostViewModel {
    enum Input {
        case stickerButtonDidTap
    }

    enum Output {
        case rectangle(rect: Rectangle)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init() { }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] in
            switch $0 {
            case .stickerButtonDidTap:
                self?.generateRectangle()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func generateRectangle() {
        let x = Int.random(in: 10..<100)
        let y = Int.random(in: 10..<100)
        let width = Int.random(in: 10..<100)
        let height = Int.random(in: 10..<100)
        
        let rectangle = Rectangle(
            position: CGPoint(x: x, y: y),
            size: CGSize(width: width, height: height)
        )

        output.send(.rectangle(rect: rectangle))
    }
}
