import Vapor

@preconcurrency
final class WebSocketController {
    private var connectedClients = [WebSocket]()
    private let roomManager: RoomManager
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        roomManager: RoomManager,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.roomManager = roomManager
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func handleConnection(_ req: Request, client: WebSocket) async {
        connectedClients.append(client)
        print("[SYSTEM] :: Client connected. Total clients: \(connectedClients.count)")
        
        // MARK: 클라이언트에서 데이터 전송 시 호출
        client.onBinary { [weak self] client, data in
            await self?.handleRequest(client: client, data: data)
        }
        
        // MARK: 연결 종료 시 호출
        client.onClose.whenComplete { [weak self] _ in
            self?.handleClientClose(client)
        }
    }
    
    private func handleRequest(client: WebSocket, data: ByteBuffer) async {
        // MARK: 어떤 요청인지 requestType을 확인합니다.
        guard let requestType = client.decodeDTO(
            data: data,
            type: WebSocketRequestType.self,
            decoder: decoder
        ) else { return }
        
        // MARK: 어떤 요청이 들어왔는지 서버에 로그를 남깁니다.
        printRequestLog(requestType, data: data)
        
        // MARK: messageType에 따른 처리를 분기합니다.
        switch requestType.messageType {
        case .signaling:
            handleSignaling(client: client, data: data)
        case .createRoom:
            await handleCreateRoom(client: client, data: data)
        case .joinRoom:
            await handleJoinRoom(client: client, data: data)
        }
    }
    
    private func handleSignaling(client: WebSocket, data: ByteBuffer) {
        guard let request = client.decodeDTO(
            data: data,
            type: SignalingRequestDTO.self,
            decoder: decoder
        ), let message = request.message else {
            print("[DEBUG] :: Message is Nil")
            return
        }
        
        connectedClients
            .filter { $0 !== client }
            .forEach { $0.send(message) }
    }
    
    private func handleCreateRoom(client: WebSocket, data: ByteBuffer) async {
        let ids = await roomManager.createRoom(client)
        
        let createRoomResponse = CreateRoomResponseDTO(
            roomID: ids.roomID,
            hostID: ids.userID
        )
        
        let response = RoomResponseDTO(
            messageType: .createRoom,
            message: createRoomResponse.toData(encoder)
        )
        
        client.sendDTO(response, encoder: encoder)
    }
    
    private func handleJoinRoom(client: WebSocket, data: ByteBuffer) async {
        // MARK: RoomRequest로 1차 디코딩
        guard let request = client.decodeDTO(
            data: data,
            type: RoomRequestDTO.self,
            decoder: decoder
        ) else { return }
        
        guard let requestMessage = request.message else { return }
        
        // MARK: RoomRequest안의 Message에 담겨있어 JoinRoomRequest로 2차 디코딩
        guard let message = client.decodeDTO(
            data: requestMessage,
            type: JoinRoomRequestMessage.self,
            decoder: decoder
        ) else { return }
        
        // MARK: 방에 참여를 시도합니다.
        let roomID = message.roomID
        let joinResult = await roomManager.joinRoom(client: client, to: roomID)
        
        switch joinResult {
        case .success(let joinRoomResponseDTO):
            // MARK: 방 참여 결과를 message에 담습니다.
            guard let message = joinRoomResponseDTO.toData(encoder) else {
                print("[DEBUG] :: Encode Failed: \(joinRoomResponseDTO)")
                return
            }
            
            // MARK: message를 RoomResponse로 래핑합니다.
            let responseDTO = RoomResponseDTO(
                messageType: .joinRoom,
                message: message
            )
            
            // MARK: 래핑한 Response를 클라이언트에 전송합니다.
            client.sendDTO(responseDTO, encoder: encoder)
     
            // MARK: 참여한 유저의 UserID를 통해 해당 User 정보를 찾습니다.
            let newUserID = joinRoomResponseDTO.userID
            guard let newUser = joinRoomResponseDTO.userList.first(where: { $0.userID == newUserID })
            else {
                print("[DEBUG] :: Failed to Find New User")
                return
            }
            
            // MARK: 방에 새로운 유저가 참가했다는 응답을 생성합니다.
            let notifyNewUserResponseDTO = NotifyNewUserResponseDTO(newUser: newUser)
            
            guard let message = notifyNewUserResponseDTO.toData(encoder) else {
                print("[DEBUG] :: Encode Failed: \(notifyNewUserResponseDTO)")
                return
            }
            
            let notifyResponseDTO = RoomResponseDTO(
                messageType: .notifyNewUser,
                message: message
            )
            
            guard let notifyResponse = notifyResponseDTO.toData(encoder) else {
                print("[DEBUG] :: Encode Failed: \(notifyResponseDTO)")
                return
            }
            
            // MARK: RoomManager에게 방에 있는 User들에게 새로운 유저가 참가했다는 알림을 전송하도록 시킵니다.
            await roomManager.notifyToUsers(
                data: notifyResponse,
                roomID: roomID,
                except: joinRoomResponseDTO.userID
            )
            
        case .failure(let error):
            print(error.localizedDescription)
            let failureResponseDTO = RoomResponseDTO(messageType: .joinRoom)
            client.sendDTO(failureResponseDTO, encoder: encoder)
        }
    }
    
    private func handleClientClose(_ client: WebSocket) {
        Task {
            connectedClients.removeAll { $0 === client }
            print("[SYSTEM] :: Client disconnected. Current clients count: \(connectedClients.count)")
            
            let cleanedCount = await roomManager.cleanRoom()
            print("[SYSTEM] :: Room cleaned! count: \(cleanedCount)")
        }
    }
    
    private func printRequestLog(_ requestType: WebSocketRequestType, data: ByteBuffer) {
        print("[REQUEST] :: MessageType: \(requestType.messageType) Received Message: \(String(describing: data))")
    }
}
