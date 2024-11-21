import Combine
import Foundation
import PhotoGetherDomainInterface

public final class ReceiveStickerListUseCaseImpl: ReceiveStickerListUseCase {
    private let eventConnectionRepository: EventConnectionRepository
    
    public init(eventConnectionRepository: EventConnectionRepository) {
        self.eventConnectionRepository = eventConnectionRepository
    }
    
    public func execute() -> AnyPublisher<[StickerEntity], Never> {
        return eventConnectionRepository.receiveStickerList().eraseToAnyPublisher()
    }
}
