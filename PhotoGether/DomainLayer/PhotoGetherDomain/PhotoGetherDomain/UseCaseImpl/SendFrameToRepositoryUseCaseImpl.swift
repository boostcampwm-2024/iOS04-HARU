import Foundation
import PhotoGetherDomainInterface

public final class SendFrameToRepositoryUseCaseImpl: SendFrameToRepositoryUseCase {
    public func execute(type: EventType, frame: FrameEntity) {
        eventConnectionRepository.mergeFrame(type: type, frame: frame)
    }
    
    private let eventConnectionRepository: EventConnectionRepository
    
    public init(eventConnectionRepository: EventConnectionRepository) {
        self.eventConnectionRepository = eventConnectionRepository
    }
}
