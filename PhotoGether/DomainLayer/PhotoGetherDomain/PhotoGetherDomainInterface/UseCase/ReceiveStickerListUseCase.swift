import Combine
import Foundation

public protocol ReceiveStickerListUseCase {
    func execute() -> AnyPublisher<[StickerEntity], Never>
}
