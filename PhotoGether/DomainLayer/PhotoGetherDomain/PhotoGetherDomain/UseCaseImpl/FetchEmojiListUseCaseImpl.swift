import Combine
import Foundation
import PhotoGetherDomainInterface

public final class FetchEmojiListUseCaseImpl: FetchEmojiListUseCase {
    public func execute() -> AnyPublisher<[EmojiEntity], Never> {
        return shapeRepository.fetchEmojiList()
    }
    
    private let shapeRepository: ShapeRepository
    
    public init(shapeRepository: ShapeRepository) {
        self.shapeRepository = shapeRepository
    }
}
