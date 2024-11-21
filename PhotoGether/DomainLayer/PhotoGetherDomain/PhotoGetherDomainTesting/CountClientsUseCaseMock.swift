import Foundation
import PhotoGetherDomainInterface

public final class CountClientsUseCaseMock: CountClientsUseCase {
    public func execute() -> Int { repository.clients.count }
    
    public init(clientCount: Int) {
        self.repository = ConnectionRepositoryMock(count: clientCount)
    }
    
    private let repository: ConnectionRepository
}
