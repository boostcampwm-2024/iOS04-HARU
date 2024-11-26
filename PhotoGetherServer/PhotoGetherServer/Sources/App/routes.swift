import Foundation
import Vapor

var roomManager = RoomManager()
let decoder = JSONDecoder()
let encoder = JSONEncoder()

func routes(_ app: Application) throws {
    var connectedClients = [WebSocket]()
    
    // WebSocket 연결을 처리하는 라우트
    app.webSocket("signaling") {
        request,
        client in
        connectedClients.append(client)
        // 클라이언트로부터 데이터를 수신할 때 호출
        client.onBinary {
            client,
            data in
            // TODO: 1. data -> JSON으로 디코딩
            guard let requestType = data.toDTO(
                type: WebSocketRequestType.self,
                decoder: decoder
            ) else {
                print("[DEBUG] :: Decode Failed to WebSocketRequestType: \(data)")
                return
            }
            
            switch requestType.messageType {
            case "signaling":
                printRequestLog(requestType, data: data)
                guard let request = data.toDTO(
                    type: SignalingRequestDTO.self,
                    decoder: decoder
                ) else {
                    print("[DEBUG] :: Decode Failed to SignalingRequestDTO: \(data)")
                    return
                }
                
                guard let data = request.message else {
                    print("[DEBUG] :: Message is Nil")
                    return
                }
                
                connectedClients
                    .filter { $0 !== client }
                    .forEach { $0.send(data) }
                
            case "createRoom":
                printRequestLog(requestType, data: data)
                let ids = roomManager.createRoom(client)
                let dto = CreateRoomResponseDTO(
                    roomID: ids.roomID,
                    hostID: ids.userID
                )
                
                guard let message = dto.toData(encoder) else {
                    print("[DEBUG] :: Encode Failed to Data: \(dto)")
                    return
                }
                
                let responseDTO = RoomResponseDTO(
                    messageType: .createRoom,
                    message: message
                )
                
                guard let response = responseDTO.toData(encoder) else {
                    print("[DEBUG] :: Encode Failed to Data: \(responseDTO)")
                    return
                }
                
                client.send(response)
                
            case "joinRoom":
                printRequestLog(requestType, data: data)
                guard let request = data.toDTO(
                    type: RoomRequestDTO.self,
                    decoder: decoder
                ) else {
                    print("[DEBUG] :: Decode Failed to RoomRequestDTO: \(data)")
                    return
                }
                
                guard let message = request.message?.toDTO(
                    type: JoinRoomRequestMessage.self,
                    decoder: decoder
                ) else {
                    print("[DEBUG] :: Decode Failed to DTO: \(request.message)")
                    return
                }
                
                let roomID = message.roomID
                
                let joinResult = roomManager.joinRoom(client: client, to: roomID)
                
                switch joinResult {
                case .success(let joinRoomResponseDTO):
                    guard let message = joinRoomResponseDTO.toData(encoder) else {
                        print("[DEBUG] :: Encode Failed to Data: \(joinRoomResponseDTO)")

                        return
                    }
                    
                    let responseDTO = RoomResponseDTO(
                        messageType: .joinRoom,
                        message: message
                    )
                    
                    guard let response = responseDTO.toData(encoder) else {
                        print("[DEBUG] :: Encoder Failed to Data: \(responseDTO)")
                        return
                    }
                
                    client.send(response)
                    
                    let newUserID = joinRoomResponseDTO.userID
                    guard let newUser = joinRoomResponseDTO.userList.first(where: { $0.userID == newUserID })
                    else {
                        print("[DEBUG] :: Failed to Find New User")
                        return
                    }
                    
                    let dto = NotifyNewUserResponseDTO(newUser: newUser)
                    
                    guard let message = dto.toData(encoder) else {
                        print("[DEBUG] :: Encoder Failed to Data: \(dto)")
                        return
                    }
                    
                    let notifyResponseDTO = RoomResponseDTO(
                        messageType: .notifyNewUser,
                        message: message
                    )
                    
                    guard let notifyResponse = notifyResponseDTO.toData(encoder) else {
                        print("Encoder Failed to Data: \(notifyResponseDTO)")
                        return
                    }
                    
                    roomManager.notifyToUsers(
                        data: notifyResponse,
                        roomID: roomID,
                        except: joinRoomResponseDTO.userID
                    )
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    let failureResponseDTO = RoomResponseDTO(messageType: .joinRoom)
                    
                    guard let response = failureResponseDTO.toData(encoder) else {
                        print("[DEBUG] :: Encoder Failed to Data: \(failureResponseDTO)")
                        return
                    }
                    
                    client.send(response)
                }
            default:
                print("[SYSTEM] :: Unknown request message type: \(requestType.messageType)")
            }
        }

        // 클라이언트가 연결을 종료할 때 호출
        client.onClose.whenComplete { _ in
            connectedClients.removeAll { $0 === client }
            let cleanedCount = roomManager.cleanRoom()
            print("[SYSTEM] :: Room Cleaned: \(cleanedCount)")
            print("[SYSTEM] :: Client disconnected. Total connected clients: \(connectedClients.count)")
        }
    }
    
    func printRequestLog(_ requestType: WebSocketRequestType, data: ByteBuffer) {
        print("[REQUEST] :: \(requestType.messageType) Request Received: \(data.readableBytes)")
    }
}
