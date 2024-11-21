import Combine
import Foundation
import PhotoGetherDomainInterface

public final class LocalShapeDataSourceImpl: ShapeDataSource {
    public func fetchEmojiData() -> AnyPublisher<[EmojiDTO], Error> {
        return Empty().eraseToAnyPublisher()
    }
    
    public init() { }
}
