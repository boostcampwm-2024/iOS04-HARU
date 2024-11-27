import Foundation

struct WebSocketRequestType: Decodable {
    let messageType: MessageType
}

enum MessageType: String, Decodable {
    case offerSDP
    case answerSDP
    case iceCandidate
    case createRoom
    case joinRoom
}
