import Combine
import Foundation

public protocol ShapeRepository {
    func fetchStickerList() -> AnyPublisher<[StickerEntity], Never>
}
