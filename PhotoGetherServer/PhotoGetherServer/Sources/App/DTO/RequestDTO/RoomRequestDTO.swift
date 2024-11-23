import Foundation

struct RoomRequestDTO: Decodable {
    var messageType: RoomMessageType
    var message: Data?
    
    init(messageType: RoomMessageType, message: Data? = nil) {
        self.messageType = messageType
        self.message = message
    }
    
    enum RoomMessageType: String, Decodable {
        case createRoom
        case joinRoom
    }
}
