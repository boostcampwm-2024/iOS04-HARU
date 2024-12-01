import Foundation
import UIKit
import PhotoGetherDomainInterface

public final class GetRemoteVideoUseCaseImpl: GetRemoteVideoUseCase {
    public func execute() -> [(UserInfo?, UIView)] {
        return connectionRepository.clients.map { ($0.remoteUserInfo, $0.remoteVideoView) }
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
