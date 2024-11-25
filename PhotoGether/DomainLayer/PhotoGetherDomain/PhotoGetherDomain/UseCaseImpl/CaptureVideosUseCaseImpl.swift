import UIKit
import PhotoGetherDomainInterface

public final class CaptureVideosUseCaseImpl: CaptureVideosUseCase {
    public func execute() -> [UIImage] {
        let localImage = [connectionRepository.capturedLocalVideo!]
        let remoteImages = connectionRepository.clients.map { $0.captureVideo() }
        
        return localImage + remoteImages
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
