import Foundation

struct RoomResponseDTO: Encodable {
    var messageType: RoomMessageType
    var message: Data?
    
    enum RoomMessageType: String, Encodable {
        case createRoom
        case joinRoom
    }
}
