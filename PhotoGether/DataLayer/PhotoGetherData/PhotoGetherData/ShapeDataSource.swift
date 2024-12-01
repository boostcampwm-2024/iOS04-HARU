import Combine
import Foundation
import PhotoGetherNetwork

public protocol ShapeDataSource {
    func fetchEmojiData(_ endPoint: EndPoint) -> AnyPublisher<[EmojiDTO], Error>
}
