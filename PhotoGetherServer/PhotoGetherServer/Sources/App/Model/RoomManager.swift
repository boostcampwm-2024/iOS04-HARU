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
            .success(JoinRoomResponseDTO(userID: userID, roomID: roomID, userList: userDTOList)) :
            .failure(RoomError.joinFailed)
    }
    
    func cleanRoom() async -> Int {
        let emptyRoomCount = rooms.filter { $0.userList.isEmpty }.count
        rooms.removeAll { $0.userList.isEmpty }
        return emptyRoomCount
    }

    func notifyNewUserEntered(dto: RoomResponseDTO, roomID: String, except userID: String) async {
        guard let targetRoom = rooms.first(where: { $0.roomID == roomID }) else {
            print("[DEBUG] :: Failed To Find Room\(roomID)")
            return
        }
        
        let targetList = targetRoom.userList.filter { $0.id != userID }
        
        targetList.forEach {
            $0.client.sendDTO(dto, encoder: encoder)
        }
    }
    
    func sendOfferSDP(dto: SessionDescriptionMessage) async {
        guard let targetRoom = rooms.first(where: { $0.roomID == dto.roomID }) else {
            print("[DEBUG] :: Failed To Find Room\(dto.roomID)")
            return
        }

        guard let receiver = targetRoom.userList.first(where: { $0.id == dto.answerID }) else {
            print("[DEBUG] :: not found receiver for offerSDP in room \(dto.roomID) \(dto.answerID ?? "nil")")
            return
        }
        
        let response = SignalingResponseDTO(
            messageType: .offerSDP,
            message: dto.toData(encoder)
        )
        
        receiver.client.sendDTO(response, encoder: encoder)
    }
    
    func sendAnswerSDP(dto: SessionDescriptionMessage) async {
        guard let targetRoom = rooms.first(where: { $0.roomID == dto.roomID }) else {
            print("[DEBUG] :: Failed To Find Room\(dto.roomID)")
            return
        }
        
        guard let receiver = targetRoom.userList.first(where: { $0.id == dto.offerID }) else {
            print("[DEBUG] :: not found receiver for answerSDP in room \(dto.roomID) \(dto.offerID)")
            return
        }
        
        let response = SignalingResponseDTO(
            messageType: .answerSDP,
            message: dto.toData(encoder)
        )
        
        receiver.client.sendDTO(response, encoder: encoder)
    }
    
    func sendIceCandidate(dto: IceCandidateMessage) async {
        guard let targetRoom = rooms.first(where: { $0.roomID == dto.roomID }) else {
            print("[DEBUG] :: Failed To Find Room\(dto.roomID)")
            return
        }
        
        guard let receiver = targetRoom.userList.first(where: { $0.id == dto.receiverID }) else {
            print("[DEBUG] :: Failed To Find User\(dto.receiverID)")
            return
        }
        let response = SignalingResponseDTO(
            messageType: .iceCandidate,
            message: dto.toData(encoder)
        )
        
        receiver.client.sendDTO(response, encoder: encoder)
    }
    
    
    private func randomRoomID() -> String {
        return "room-\(UUID().uuidString)"
    }
    
    private func randomUserID() -> String {
        return "user-\(UUID().uuidString)"
    }
}
