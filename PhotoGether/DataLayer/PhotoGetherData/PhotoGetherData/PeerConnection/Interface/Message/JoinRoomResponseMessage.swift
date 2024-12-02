import Foundation
import PhotoGetherDomainInterface

public struct JoinRoomResponseMessage: Decodable {
    public let userID: String // MARK: 참가 요청을 보낸 유저 ID
    public let roomID: String
    public let userList: [UserDTO] // MARK: 참가 요청을 보낸 유저를 포함한 방 유저 리스트
    
    public init(userID: String, roomID: String, userList: [UserDTO]) {
        self.userID = userID
        self.roomID = roomID
        self.userList = userList
    }
    
    public func toEntity() -> JoinRoomEntity {
        let userList = self.userList.map { $0.toEntity() }
        return JoinRoomEntity(userID: self.userID, roomID: self.roomID, userList: userList)
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
