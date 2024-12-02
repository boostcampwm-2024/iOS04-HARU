import UIKit
import Combine
import PhotoGetherDomainInterface

public final class DidEnterNewUserPublisherUseCaseImpl: DidEnterNewUserPublisherUseCase {
    public func publisher() -> AnyPublisher<(UserInfo, UIView), Never> {
        return connectionRepository.didEnterNewUserPublisher
    }
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
