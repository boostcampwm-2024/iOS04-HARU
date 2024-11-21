import Combine
import Foundation

public protocol FetchEmojiListUseCase {
    func execute() -> AnyPublisher<[EmojiEntity], Never>
}
