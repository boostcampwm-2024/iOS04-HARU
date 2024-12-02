import Combine
import Foundation

public protocol ShapeRepository {
    func fetchEmojiList(_ group: EmojiGroup) -> AnyPublisher<[EmojiEntity], Never>
}
