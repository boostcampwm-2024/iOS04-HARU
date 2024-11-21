import UIKit
import PhotoGetherDomainInterface

public final class CaptureVideosUseCaseImpl: CaptureVideosUseCase {
    public func execute() -> [UIImage] {
        let localImage = [connectionRepository.clients[0].captureVideos()[0]]
        let remoteImages = connectionRepository.clients.map { $0.captureVideos()[1] }
        
        return localImage + remoteImages
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
