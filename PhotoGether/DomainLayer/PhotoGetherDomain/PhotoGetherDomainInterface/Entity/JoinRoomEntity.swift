import Foundation

public struct JoinRoomEntity {
    public let userID: String
    public let userList: [UserEntity]
    
    public init(userID: String, userList: [UserEntity]) {
        self.userID = userID
        self.userList = userList
    }
}
