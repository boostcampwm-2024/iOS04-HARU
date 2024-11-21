import Foundation
import PhotoGetherDomainInterface

public final class ConnectionRepositoryImpl: ConnectionRepository {
    public var clients: [ConnectionClient]
    
    public init(clients: [ConnectionClient]) {
        self.clients = clients
    }
}
