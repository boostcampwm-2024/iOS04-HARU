import Combine
import Foundation

public protocol FetchEmojiListUseCase {
    func execute(_ group: EmojiGroup) -> AnyPublisher<[EmojiEntity], Never>
}
