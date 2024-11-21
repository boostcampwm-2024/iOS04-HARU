import Foundation
import PhotoGetherDomainInterface

public final class SendOfferUseCaseImpl: SendOfferUseCase {
    public func execute() {
        // TODO: 특정 Peer에게만 Offer를 보내도록 수정해야 함
        guard let client = repository.clients.first else { return }
        client.sendOffer()
    }
    
    private let repository: ConnectionRepository
    
    public init(repository: ConnectionRepository) {
        self.repository = repository
    }
}
