import Combine
import Foundation
import PhotoGetherDomainInterface

public final class FetchStickerListUseCaseImpl: FetchStickerListUseCase {
    public func execute() -> AnyPublisher<[Data], Never> {
        return shapeRepository.fetchStickerList()
    }
    
    private let shapeRepository: ShapeRepository
    
    public init(shapeRepository: ShapeRepository) {
        self.shapeRepository = shapeRepository
    }
}
