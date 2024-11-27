import Foundation
import PhotoGetherDomainInterface

public final class SendOfferUseCaseImpl: SendOfferUseCase {
    public func execute() -> Bool {
        repository.sendOffer()
    }
    
    private let repository: ConnectionRepository
    
    public init(repository: ConnectionRepository) {
        self.repository = repository
    }
}
