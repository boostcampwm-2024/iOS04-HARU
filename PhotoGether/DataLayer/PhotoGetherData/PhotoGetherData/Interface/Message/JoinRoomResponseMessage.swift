import Foundation
import PhotoGetherDomainInterface

public struct JoinRoomResponseMessage: Decodable {
    public let userID: String
    public let userList: [UserDTO]
    
    public init(userID: String, userList: [UserDTO]) {
        self.userID = userID
        self.userList = userList
    }
    
    public func toEntity() -> JoinRoomEntity {
        let userList = self.userList.map { $0.toEntity() }
        return JoinRoomEntity(userID: self.userID, userList: userList)
    }
}

public struct UserDTO: Decodable {
    public let userID: String
    public let nickname: String
    public let initialPosition: Int
    
    public func toEntity() -> UserEntity {
        UserEntity(userID: self.userID, nickname: self.nickname, initialPosition: self.initialPosition)
    }
}
