import Combine
import Foundation
import PhotoGetherDomainInterface

public final class FetchEmojiListUseCaseImpl: FetchEmojiListUseCase {
    public func execute(_ group: EmojiGroup) -> AnyPublisher<[EmojiEntity], Never> {
        return shapeRepository.fetchEmojiList(group)
    }
    
    private let shapeRepository: ShapeRepository
    
    public init(shapeRepository: ShapeRepository) {
        self.shapeRepository = shapeRepository
    }
}
