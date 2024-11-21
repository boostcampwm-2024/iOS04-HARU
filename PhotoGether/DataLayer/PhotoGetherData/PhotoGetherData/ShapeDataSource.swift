import Combine
import Foundation

public protocol ShapeDataSource {
    func fetchStickerData() -> AnyPublisher<[StickerDTO], Error>
}
