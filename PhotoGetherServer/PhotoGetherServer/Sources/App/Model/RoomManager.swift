import Vapor

actor RoomManager {
    private var rooms: [Room] = []
    private let encoder = JSONEncoder()
    
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
        guard let targetRoom = rooms.first(where: { $0.roomID == roomID }) else {
            print("[DEBUG] :: Failed To Find Room\(roomID)")
            return
        }
        
        let targetList = targetRoom.userList.filter { $0.id != userID }
        
        targetList.forEach {
            $0.client.send(data)
        }
    }
    
    func sendSDPToRoom(dto: SessionDescriptionMessage) async {
        guard let targetRoom = rooms.first(where: { $0.roomID == dto.roomID }) else {
            print("[DEBUG] :: Failed To Find Room\(dto.roomID)")
            return
        }
        
        let targetList = targetRoom.userList.filter { $0.id != dto.userID }
        let response = SignalingResponseDTO(
            messageType: .sdp,
            message: dto.toData(encoder)
        )
        
        targetRoom.userList.forEach {
            $0.client.sendDTO(response, encoder: encoder)
        }
    }
    
    func sendIceCandidateToRoom(dto: IceCandidateMessage) async {
        guard let targetRoom = rooms.first(where: { $0.roomID == dto.roomID }) else {
            print("[DEBUG] :: Failed To Find Room\(dto.roomID)")
            return
        }
        
        let targetList = targetRoom.userList.filter { $0.id != dto.userID }
        let response = SignalingResponseDTO(
            messageType: .iceCandidate,
            message: dto.toData(encoder)
        )
        
        targetRoom.userList.forEach {
            $0.client.sendDTO(response, encoder: encoder)
        }
    }
    
    func sendSDPToUser(dto: SessionDescriptionMessage) async {
        guard let targetRoom = rooms.first(where: { $0.roomID == dto.roomID }) else {
            print("[DEBUG] :: Failed To Find Room\(dto.roomID)")
            return
        }
        
        guard let targetUser = targetRoom.userList.filter({ $0.id == dto.userID }).first else {
            print("[DEBUG] :: Failed To Find User\(dto.userID)")
            return
        }
        let response = SignalingResponseDTO(
            messageType: .sdp,
            message: dto.toData(encoder)
        )
        
        targetUser.client.sendDTO(response, encoder: encoder)
    }
    
    func sendIceCandidateToUser(dto: IceCandidateMessage) async {
        guard let targetRoom = rooms.first(where: { $0.roomID == dto.roomID }) else {
            print("[DEBUG] :: Failed To Find Room\(dto.roomID)")
            return
        }
        
        guard let targetUser = targetRoom.userList.filter({ $0.id == dto.userID }).first else {
            print("[DEBUG] :: Failed To Find User\(dto.userID)")
            return
        }
        let response = SignalingResponseDTO(
            messageType: .iceCandidate,
            message: dto.toData(encoder)
        )
        
        targetUser.client.sendDTO(response, encoder: encoder)
    }
    
    
    private func randomRoomID() -> String {
        return "room-\(UUID().uuidString)"
    }
    
    private func randomUserID() -> String {
        return "user-\(UUID().uuidString)"
    }
}
