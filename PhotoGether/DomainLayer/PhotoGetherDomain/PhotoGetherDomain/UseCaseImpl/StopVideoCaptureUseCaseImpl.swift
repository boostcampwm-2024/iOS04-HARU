import Foundation
import Combine
import PhotoGetherDomainInterface

public final class StopVideoCaptureUseCaseImpl: StopVideoCaptureUseCase {
    @discardableResult
    public func execute() -> Bool {
        connectionRepository.stopCaptureLocalVideo()
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
