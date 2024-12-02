import Foundation
import PhotoGetherNetwork

struct SignalingResponseDTO: WebSocketResponsable {
    var messageType: SignalingMessageType
    var message: Data?
    
    init(messageType: SignalingMessageType, message: Data? = nil) {
        self.messageType = messageType
        self.message = message
    }
    
    enum SignalingMessageType: String, Decodable {
        case offerSDP
        case answerSDP
        case iceCandidate
    }
}
