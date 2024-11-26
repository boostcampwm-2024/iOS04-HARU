import Foundation

public struct NotifyNewUserEntity {
    public let newUser: UserEntity
    
    public init(newUser: UserEntity) {
        self.newUser = newUser
    }
}
