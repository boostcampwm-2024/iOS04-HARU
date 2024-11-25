import Combine
import Foundation
import PhotoGetherNetwork

public final class RemoteShapeDataSourceImpl: ShapeDataSource {
    // TODO: 페이징 적용 필요
    public func fetchEmojiData(_ endpoint: EndPoint) -> AnyPublisher<[EmojiDTO], Error> {
        return Request.requestJSON(endpoint)
            .map { (emojiDTOs: [EmojiDTO]) -> [EmojiDTO] in
                if let data = try? JSONEncoder().encode(emojiDTOs),
                   let url = endpoint.request().url {
                    CacheManager().save(key: url.absoluteString, data: data)
                }
                
                return emojiDTOs
            }
            .eraseToAnyPublisher()
    }
    
    public init() { }
}
