import Foundation
import UIKit
import PhotoGetherDomainInterface

public final class GetRemoteVideoUseCaseImpl: GetRemoteVideoUseCase {
    public func execute() -> [UIView] {
        connectionRepository.clients.map { $0.remoteVideoView }
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
