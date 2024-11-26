package struct JoinRoomResponseDTO: Encodable {
    let userID: String
    let userList: [UserDTO]
    
    package init(userID: String, userList: [UserDTO]) {
        self.userID = userID
        self.userList = userList
    }
}

package struct UserDTO: Encodable {
    let userID: String
    let nickname: String
    let initialPosition: Int
}
