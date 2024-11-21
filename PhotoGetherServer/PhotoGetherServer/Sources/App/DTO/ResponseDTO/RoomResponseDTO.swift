import Foundation

struct RoomResponseDTO: WebSocketRequestable {
    var messageType: RoomMessageType
    var message: Data?
    
    enum RoomMessageType: String, Decodable {
        case createRoom
        case joinRoom
    }
}
