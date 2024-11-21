import Foundation
import PhotoGetherNetwork

struct RoomRequestDTO: WebSocketRequestable {
    var messageType: RoomMessageType
    var message: Data?
    
    init(messageType: RoomMessageType, body: Data? = nil) {
        self.messageType = messageType
    }
    
    enum RoomMessageType: String, Encodable {
        case createRoom
        case joinRoom
    }
}
