package struct JoinRoomResponseDTO: Encodable {
    let userID: String
    let users: [UserDTO]
    
    package init(userID: String, users: [UserDTO]) {
        self.userID = userID
        self.users = users
    }
}

package struct UserDTO: Encodable {
    let userID: String
    let nickname: String
    let initialPosition: Int
}
