import Combine
import Foundation
import PhotoGetherDomainInterface

public final class LocalShapeDataSourceImpl: ShapeDataSource {
    public func fetchStickerData() -> AnyPublisher<[StickerDTO], Error> {
        return Empty().eraseToAnyPublisher()
    }
    
    public init() { }
}
