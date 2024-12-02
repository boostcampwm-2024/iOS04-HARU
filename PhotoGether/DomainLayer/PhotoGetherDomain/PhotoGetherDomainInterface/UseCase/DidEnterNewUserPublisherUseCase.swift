import UIKit
import Combine

public protocol DidEnterNewUserPublisherUseCase {
    func publisher() -> AnyPublisher<(UserInfo, UIView), Never>
}
