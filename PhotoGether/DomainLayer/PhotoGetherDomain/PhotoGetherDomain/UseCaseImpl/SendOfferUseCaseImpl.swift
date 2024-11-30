import Foundation
import Combine
import PhotoGetherDomainInterface

public final class SendOfferUseCaseImpl: SendOfferUseCase {
    public func execute() -> AnyPublisher<Void, Error> {
        Future { promise in
            Task {
                do {
                    try await self.repository.sendOffer()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private let repository: ConnectionRepository
    
    public init(repository: ConnectionRepository) {
        self.repository = repository
    }
}
