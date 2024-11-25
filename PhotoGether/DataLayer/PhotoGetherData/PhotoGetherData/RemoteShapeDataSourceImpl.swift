import Combine
import Foundation
import PhotoGetherNetwork

public final class RemoteShapeDataSourceImpl: ShapeDataSource {
    // TODO: 페이징 적용 필요
    public func fetchEmojiData(_ endpoint: EndPoint) -> AnyPublisher<[EmojiDTO], Error> {
        return Request.requestJSON(endpoint)
    }
    
    public init() { }
}
