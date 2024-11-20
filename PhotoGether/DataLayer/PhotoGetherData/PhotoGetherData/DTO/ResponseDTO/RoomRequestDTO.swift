import Foundation
import PhotoGetherNetwork

struct RoomRequestDTO: WebSocketRequestable {
    var type: RoomMessageType
    var message: Data?
    
    init(type: RoomMessageType, body: Data? = nil) {
        self.type = type
    }
    
    enum RoomMessageType: String, Encodable {
        case createRoom
        case joinRoom
    }
}
