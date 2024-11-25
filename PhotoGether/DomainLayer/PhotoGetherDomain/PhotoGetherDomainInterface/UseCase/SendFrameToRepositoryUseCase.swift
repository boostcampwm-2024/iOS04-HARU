import Combine
import Foundation

public protocol SendFrameToRepositoryUseCase {
    func execute(type: EventType, frame: FrameEntity)
}
