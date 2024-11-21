import Combine
import Foundation
import PhotoGetherDomainInterface

public final class FetchEmojiListUseCaseMock: FetchEmojiListUseCase {
    private let repository: ShapeRepository = ShapeRepositoryMock(imageNameList: [
        "blackHeart", "bug", "cat",
        "crown", "dog", "lips",
        "parkBug", "racoon", "redHeart",
        "star", "sunglasses", "tree",
    ])
    
    public init() { }
    
    public func execute() -> AnyPublisher<[EmojiEntity], Never> {
        return repository.fetchEmojiList()
    }
}
