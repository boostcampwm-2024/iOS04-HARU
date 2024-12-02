import Foundation
import PhotoGetherDomainInterface

public struct NotifyNewUserMessage: Decodable {
    public let newUser: UserDTO
    
    public init(newUser: UserDTO) {
        self.newUser = newUser
    }
    
    public func toEntity() -> NotifyNewUserEntity {
        NotifyNewUserEntity(newUser: self.newUser.toEntity())
    }
}
