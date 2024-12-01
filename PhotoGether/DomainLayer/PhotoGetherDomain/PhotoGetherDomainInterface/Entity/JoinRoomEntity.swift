import Foundation

public struct JoinRoomEntity {
    public let userID: String
    public let roomID: String
    public let userList: [UserEntity]
    
    public init(userID: String, roomID: String, userList: [UserEntity]) {
        self.userID = userID
        self.roomID = roomID
        self.userList = userList
    }
}
