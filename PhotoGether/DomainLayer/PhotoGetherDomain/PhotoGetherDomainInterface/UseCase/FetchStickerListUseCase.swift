import Combine
import Foundation

public protocol FetchStickerListUseCase {
    func execute() -> AnyPublisher<[StickerEntity], Never>
}
