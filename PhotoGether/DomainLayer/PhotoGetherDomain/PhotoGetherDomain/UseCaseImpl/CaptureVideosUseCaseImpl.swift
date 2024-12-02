import UIKit
import PhotoGetherDomainInterface
import DesignSystem

public final class CaptureVideosUseCaseImpl: CaptureVideosUseCase {
    public func execute() -> [UIImage] {
        guard let localImage = connectionRepository.capturedLocalVideo
        else { return [
            PTGImage.temp1.image,
            PTGImage.temp2.image,
            PTGImage.temp3.image,
            PTGImage.temp4.image]
        }
        let remoteImages = connectionRepository.clients.map { $0.captureVideo() }
        
        return [localImage] + remoteImages
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
