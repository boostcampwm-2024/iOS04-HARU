import Foundation
import Combine

final class EditPhotoRoomHostViewModel {
    struct Input {
        let didStickerButtonTapped: AnyPublisher<Void, Never>
    }

    struct Output {
        let rectangle: AnyPublisher<Rectangle, Never>
    }
    
    private let rectangleSubject = PassthroughSubject<Rectangle, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    func bind(input: Input) {
        input.didStickerButtonTapped
            .sink { [weak self]  in
                guard let self else { return }
                self.generateRectangle()
            }
            .store(in: &cancellables)
    }
    
    func bindOutput() -> Output {
        return Output(rectangle: rectangleSubject.eraseToAnyPublisher())
    }
    
    func generateRectangle() {
        let rectangle = Rectangle(
            position: CGPoint(x: 30, y: 40),
            size: CGSize(width: 30, height: 30)
        )
        
        rectangleSubject.send(rectangle)
    }
}
