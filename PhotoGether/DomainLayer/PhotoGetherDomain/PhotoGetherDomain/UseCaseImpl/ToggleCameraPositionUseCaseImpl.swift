import Foundation
import Combine
import PhotoGetherDomainInterface

public final class ToggleCameraPositionUseCaseImpl: ToggleCameraPositionUseCase {
    public func execute() {
        return connectionRepository.toggleCameraPosition()
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
