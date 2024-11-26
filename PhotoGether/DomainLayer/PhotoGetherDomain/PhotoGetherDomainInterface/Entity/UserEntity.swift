import Foundation

public struct UserEntity {
    public let userID: String
    public let nickname: String
    public let initialPosition: Int
    
    public init(userID: String, nickname: String, initialPosition: Int) {
        self.userID = userID
        self.nickname = nickname
        self.initialPosition = initialPosition
    }
}
