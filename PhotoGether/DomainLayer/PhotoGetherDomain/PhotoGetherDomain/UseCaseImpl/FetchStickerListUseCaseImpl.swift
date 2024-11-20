import Combine
import Foundation
import PhotoGetherDomainInterface

public final class FetchStickerListUseCaseImpl: FetchStickerListUseCase {
    public func execute() -> AnyPublisher<[StickerEntity], Never> {
        return shapeRepository.fetchStickerList()
    }
    
    private let shapeRepository: ShapeRepository
    
    public init(shapeRepository: ShapeRepository) {
        self.shapeRepository = shapeRepository
    }
}
