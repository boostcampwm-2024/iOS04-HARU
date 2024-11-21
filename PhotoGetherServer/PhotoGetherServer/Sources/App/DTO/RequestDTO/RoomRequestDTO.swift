import Foundation

struct RoomRequestDTO: Decodable {
    var messageType: RoomMessageType
    var message: Data?
    
    init(messageType: RoomMessageType, body: Data? = nil) {
        self.messageType = messageType
    }
    
    enum RoomMessageType: String, Decodable {
        case createRoom
        case joinRoom
    }
}
