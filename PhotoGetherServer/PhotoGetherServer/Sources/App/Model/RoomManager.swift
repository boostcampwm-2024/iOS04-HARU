import Vapor

final class RoomManager {
    private var rooms: [Room] = []
    
    func createRoom(_ client: WebSocket) -> (roomID: String, userID: String) {
        let roomID = randomRoomID()
        let userID = randomUserID()
        
        let user = User(id: userID, client: client)
        var room = Room(roomID: roomID)
        
        room.invite(user: user)
        self.rooms.append(room)
        
        return (roomID, userID)
    }
    
    func joinRoom(client: WebSocket, to roomID: String) -> Result<JoinRoomResponseDTO, Error> {
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
            .success(JoinRoomResponseDTO(userID: userID, users: userDTOList)) :
            .failure(RoomError.joinFailed)
    }
    
    private func randomRoomID() -> String {
        return "room-\(UUID().uuidString)"
    }
    
    private func randomUserID() -> String {
        return "user-\(UUID().uuidString)"
    }
}
