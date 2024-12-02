import Foundation
import PhotoGetherNetwork

struct RoomRequestDTO: WebSocketRequestable {
    var messageType: RoomMessageType
    var message: Data?
    
    init(messageType: RoomMessageType, message: Data? = nil) {
        self.messageType = messageType
        self.message = message
    }
    
    enum RoomMessageType: String, Encodable {
        case createRoom
        case joinRoom
    }
}
