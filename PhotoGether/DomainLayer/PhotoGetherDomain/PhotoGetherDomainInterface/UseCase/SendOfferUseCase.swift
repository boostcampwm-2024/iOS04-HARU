import Foundation
import Combine

public protocol SendOfferUseCase {
    func execute() -> AnyPublisher<Void, Error>
}
