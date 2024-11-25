import Foundation
import Vapor

var roomManager = RoomManager()
let decoder = JSONDecoder()
let encoder = JSONEncoder()

func routes(_ app: Application) throws {
    var connectedClients = [WebSocket]()
    
    // WebSocket 연결을 처리하는 라우트
    app.webSocket("signaling") { request, client in
        connectedClients.append(client)
        
        // 클라이언트가 연결될 때 호출
        print("Client connected. Total connected clients: \(connectedClients.count)")
        
        // 클라이언트로부터 데이터를 수신할 때 호출
        client.onBinary { client, data in
            print("Received binary data of size: \(data.readableBytes)")
            // TODO: 1. data -> JSON으로 디코딩
            guard let requestType = data.toDTO(type: WebSocketRequestType.self) else {
                print("Decode Failed to WebSocketRequestType: \(data)")
                return
            }
            
            switch requestType.messageType {
            case "signaling":
                guard let request = data.toDTO(type: SignalingRequestDTO.self) else {
                    print("Decode Failed to SignalingRequestDTO: \(data)")
                    return
                }
                
                guard let data = request.message else {
                    print("Message is Nil")
                    return
                }
                
                connectedClients
                    .filter { $0 !== client }
                    .forEach { $0.send(data) }
                
            case "createRoom":
                guard let request = data.toDTO(type: RoomRequestDTO.self) else {
                    print("Decode Failed to RoomRequestDTO: \(data)")
                    return
                }
                
                let ids = roomManager.createRoom(client)
                let dto = CreateRoomResponseDTO(roomID: ids.roomID, userID: ids.userID)
                
                guard let message = dto.toData(encoder) else {
                    print("Encode Failed to Data: \(dto)")
                    return
                }
                
                let responseDTO = RoomResponseDTO(messageType: .createRoom, message: message)
                
                guard let response = responseDTO.toData(encoder) else {
                    print("Encode Failed to Data: \(responseDTO)")
                    return
                }
                
                client.send(response)
                
            case "joinRoom":
                print("joinRoom")
            default:
                print("Unknown request message type: \(requestType.messageType)")
            }
            // TODO: 2. type을 보고 수행할 명령을 선택
            
//            connectedClients
//                .filter { $0 !== client }
//                .forEach { $0.send(data) }
        }

        // 클라이언트가 연결을 종료할 때 호출
        client.onClose.whenComplete { _ in
            connectedClients.removeAll { $0 === client }
            print("Client disconnected. Total connected clients: \(connectedClients.count)")
        }
    }
}
