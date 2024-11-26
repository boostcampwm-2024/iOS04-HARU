import Combine
import Foundation
import PhotoGetherDomainInterface

public final class ReceiveFrameUseCaseImpl: ReceiveFrameUseCase {
    private let eventConnectionRepository: EventConnectionRepository
    
    public init(eventConnectionRepository: EventConnectionRepository) {
        self.eventConnectionRepository = eventConnectionRepository
    }
    
    public func execute() -> AnyPublisher<FrameEntity, Never> {
        return eventConnectionRepository.receiveFrameEntity().eraseToAnyPublisher()
    }
}
