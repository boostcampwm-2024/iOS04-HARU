import Foundation
import PhotoGetherNetwork

struct RoomResponseDTO: WebSocketResponsable {
    var messageType: RoomMessageType
    var message: Data?
    
    enum RoomMessageType: String, Decodable {
        case createRoom
        case joinRoom
    }
}
