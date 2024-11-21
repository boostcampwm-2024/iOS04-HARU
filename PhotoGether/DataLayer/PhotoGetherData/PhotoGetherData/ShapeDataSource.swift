import Combine
import Foundation

public protocol ShapeDataSource {
    func fetchEmojiData() -> AnyPublisher<[EmojiDTO], Error>
}
