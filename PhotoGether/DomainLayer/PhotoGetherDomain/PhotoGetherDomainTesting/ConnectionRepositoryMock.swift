import Foundation
import PhotoGetherDomainInterface

public final class ConnectionRepositoryMock: ConnectionRepository {
    public var clients: [ConnectionClient] = []
    
    public init(count: Int) {
        for _ in 0..<count {
            self.clients.append(ConnectionClientMock())
        }
    }
}
