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
    
    private func randomRoomID() -> String {
        return "room-\(UUID().uuidString)"
    }
    
    private func randomUserID() -> String {
        return "user-\(UUID().uuidString)"
    }
}
