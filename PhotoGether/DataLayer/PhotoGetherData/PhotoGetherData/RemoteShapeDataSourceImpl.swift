import Combine
import Foundation
import PhotoGetherNetwork

public final class RemoteShapeDataSourceImpl: ShapeDataSource {
    // TODO: 페이징 적용 필요
    public func fetchEmojiData() -> AnyPublisher<[EmojiDTO], Error> {
        return Request.requestJSON(EmojiEndPoint())
    }
    
    public init() { }
}
