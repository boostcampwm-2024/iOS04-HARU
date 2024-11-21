import Combine
import Foundation

public protocol ShapeRepository {
    func fetchEmojiList() -> AnyPublisher<[EmojiEntity], Never>
}
