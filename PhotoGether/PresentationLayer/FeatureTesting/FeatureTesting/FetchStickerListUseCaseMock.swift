import Combine
import Foundation
import PhotoGetherDomainInterface
import PhotoGetherDomainTesting

public final class FetchStickerListUseCaseMock: FetchStickerListUseCase {
    private let repository: ShapeRepository = ShapeRepositoryMock(imageNameList: [
        "blackHeart", "bug", "cat",
        "crown", "dog", "lips",
        "parkBug", "racoon", "redHeart",
        "star", "sunglasses", "tree",
    ])
    
    public init() { }
    
    public func execute() -> AnyPublisher<[Data], Never> {
        return repository.fetchStickerList()
    }
}
