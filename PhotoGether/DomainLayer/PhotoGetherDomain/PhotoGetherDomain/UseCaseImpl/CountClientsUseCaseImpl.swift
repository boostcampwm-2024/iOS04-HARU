import Foundation
import PhotoGetherDomainInterface

public final class CountClientsUseCaseImpl: CountClientsUseCase {
    public func execute() -> Int { repository.clients.count }
    
    private let repository: ConnectionRepository
    
    init(repository: ConnectionRepository) {
        self.repository = repository
    }
}
