import Combine
import Foundation

public protocol SendStickerToRepositoryUseCase {
    func execute(type: EventType, sticker: StickerEntity)
}
