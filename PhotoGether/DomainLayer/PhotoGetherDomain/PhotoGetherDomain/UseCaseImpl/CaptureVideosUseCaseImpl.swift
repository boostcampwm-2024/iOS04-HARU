import UIKit
import PhotoGetherDomainInterface
import DesignSystem

public final class CaptureVideosUseCaseImpl: CaptureVideosUseCase {
    public func execute() -> [UIImage] {
        let image = connectionRepository.capturedLocalVideo
        let localImage = [connectionRepository.capturedLocalVideo ?? PTGImage.temp1.image]
        let remoteImages = connectionRepository.clients.map { $0.captureVideo() }
        
        
        return localImage + remoteImages
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
