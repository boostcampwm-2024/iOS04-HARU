import Combine
import Foundation

public protocol EventConnectionRepository {
    func receiveStickerList() -> AnyPublisher<[StickerEntity], Never>
    func mergeSticker(type: EventType, sticker: StickerEntity)
    
    func receiveFrameEntity() -> AnyPublisher<FrameEntity, Never>
    func mergeFrame(type: EventType, frame: FrameEntity)
}
