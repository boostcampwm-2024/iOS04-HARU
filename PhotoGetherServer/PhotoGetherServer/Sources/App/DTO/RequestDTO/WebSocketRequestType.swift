import Foundation

struct WebSocketRequestType: Decodable {
    let messageType: MessageType
}

enum MessageType: String, Decodable {
    case sdp
    case iceCandidate
    case createRoom
    case joinRoom
}
