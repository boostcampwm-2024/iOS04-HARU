package struct JoinRoomResponseDTO: Encodable {
    let userID: String
    let roomID: String
    let userList: [UserDTO]
    
    package init(userID: String, roomID: String, userList: [UserDTO]) {
        self.userID = userID
        self.roomID = roomID
        self.userList = userList
    }
}

package struct UserDTO: Encodable {
    let userID: String
    let nickname: String
    let initialPosition: Int
}
