import Combine
import Foundation
import UIKit

public final class EditPhotoRoomHostViewModel {
    enum Input {
        case frameButtonDidTap
        case stickerButtonDidTap
        case nextButtonDidTap
    }

    enum Output {
        case rectangle(rect: Rectangle)
        case frameImage(image: UIImage)
        case showSharePhoto
    }
    
    private let frameImageGenerator: FrameImageGenerator
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init(frameImageGenerator: FrameImageGenerator) {
        self.frameImageGenerator = frameImageGenerator
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .stickerButtonDidTap:
                self?.generateRectangle()
            case .frameButtonDidTap:
                self?.toggleFrame()
            case .nextButtonDidTap:
                self?.showSharePhoto()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    func generateFrameImage() -> UIImage {
        return frameImageGenerator.generate()
    }
    
    func toggleFrame() {
        switch frameImageGenerator.frameType {
        case .defaultBlack:
            frameImageGenerator.changeFrame(to: .defaultWhite)
        case .defaultWhite:
            frameImageGenerator.changeFrame(to: .defaultBlack)
        }
        let image = frameImageGenerator.generate()
        output.send(.frameImage(image: image))
    }
    
    private func showSharePhoto() {
        output.send(.showSharePhoto)
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
