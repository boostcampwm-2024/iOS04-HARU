import Foundation
import PhotoGetherDomainInterface

public final class sendStickerToRepositoryUseCaseImpl: SendStickerToRepositoryUseCase {
    public func execute(type: EventType, sticker: StickerEntity) {
        eventConnectionRepository.mergeSticker(type: type, sticker: sticker)
    }
    
    private let eventConnectionRepository: EventConnectionRepository
    
    public init(eventConnectionRepository: EventConnectionRepository) {
        self.eventConnectionRepository = eventConnectionRepository
    }
    
}
