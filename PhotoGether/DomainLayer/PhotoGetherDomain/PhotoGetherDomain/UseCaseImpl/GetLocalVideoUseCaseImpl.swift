import Foundation
import UIKit
import PhotoGetherDomainInterface

public final class GetLocalVideoUseCaseImpl: GetLocalVideoUseCase {
    public func execute() -> UIView {
        connectionRepository.clients[0].localVideoView
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
