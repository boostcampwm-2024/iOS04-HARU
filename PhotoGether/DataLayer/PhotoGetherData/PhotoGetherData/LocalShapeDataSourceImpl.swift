import Combine
import Foundation
import PhotoGetherDomainInterface
import PhotoGetherNetwork

public final class LocalShapeDataSourceImpl: ShapeDataSource {
    public func fetchEmojiData(_ endpoint: EndPoint) -> AnyPublisher<[EmojiDTO], Error> {
        guard let url = endpoint.request().url else { return Empty().eraseToAnyPublisher() }
        
        return CacheManager().loadPublisher(key: url.absoluteString)
            .compactMap { $0 }
            .decode(type: [EmojiDTO].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    public init() { }
}
