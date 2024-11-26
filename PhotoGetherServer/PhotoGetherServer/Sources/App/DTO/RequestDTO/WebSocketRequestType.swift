import Foundation

struct WebSocketRequestType: Decodable {
    let messageType: MessageType
}

enum MessageType: String, Decodable {
    case signaling
    case createRoom
    case joinRoom
}
