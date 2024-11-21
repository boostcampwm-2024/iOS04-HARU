import Combine
import Foundation
import PhotoGetherDomainInterface

public final class FetchStickerListUseCaseMock: FetchStickerListUseCase {
    private let repository: ShapeRepository = ShapeRepositoryMock(imageNameList: [
        "blackHeart", "bug", "cat",
        "crown", "dog", "lips",
        "parkBug", "racoon", "redHeart",
        "star", "sunglasses", "tree",
    ])
    
    public init() { }
    
    public func execute() -> AnyPublisher<[StickerEntity], Never> {
        return repository.fetchStickerList()
    }
}
