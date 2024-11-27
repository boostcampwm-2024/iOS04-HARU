import Vapor

actor RoomManager {
    private var rooms: [Room] = []
    
    func createRoom(_ client: WebSocket) async -> (roomID: String, userID: String) {
        let roomID = randomRoomID()
        let userID = randomUserID()
        
        let user = User(id: userID, client: client)
        let room = Room(roomID: roomID)
        
        room.invite(user: user)
        self.rooms.append(room)
        
        return (roomID, userID)
    }
    
    func joinRoom(client: WebSocket, to roomID: String) async -> Result<JoinRoomResponseDTO, Error> {
        let userID = randomUserID()
        
        let user = User(id: userID, client: client)
        guard let targetRoom = rooms.first(where: { $0.roomID == roomID }) else {
            return .failure(RoomError.joinFailed)
        }
        
        let isSuccessInvite = targetRoom.invite(user: user)
        let userDTOList = targetRoom.userList.map {
            let userID = $0.id
            let nickname = String($0.id.suffix(4))
            let index = targetRoom.userList.firstIndex(of: $0) ?? -1
            
            return UserDTO(userID: userID, nickname: nickname, initialPosition: index)
        }
        
        return isSuccessInvite ?
            .success(JoinRoomResponseDTO(userID: userID, userList: userDTOList)) :
            .failure(RoomError.joinFailed)
    }
    
    func cleanRoom() async -> Int {
        let emptyRoomCount = rooms.filter { $0.userList.isEmpty }.count
        rooms.removeAll { $0.userList.isEmpty }
        return emptyRoomCount
    }

    func notifyToUsers(data: Data, roomID: String, except userID: String) async {
        guard let room = rooms.first(where: { $0.roomID == roomID }) else {
            print("Failed To Find Room")
            return
        }
        
        let targetList = room.userList.filter { $0.id != userID }
        
        targetList.forEach {
            $0.client.send(data)
        }
    }
    
    private func randomRoomID() -> String {
        return "room-\(UUID().uuidString)"
    }
    
    private func randomUserID() -> String {
        return "user-\(UUID().uuidString)"
    }
}
