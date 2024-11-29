import Foundation
import UIKit
import PhotoGetherDomainInterface

public final class GetRemoteVideoUseCaseImpl: GetRemoteVideoUseCase {
    public func execute() -> [UIView] {
        let sortedClients = connectionRepository.clients
            .sorted { lhs, rhs in
                let lhsPosition = lhs.remoteUserInfo?.viewPosition.rawValue ?? Int.max
                let rhsPosition = rhs.remoteUserInfo?.viewPosition.rawValue ?? Int.max
                return lhsPosition < rhsPosition
            }
            .map { $0.remoteVideoView }
        
        return sortedClients
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
