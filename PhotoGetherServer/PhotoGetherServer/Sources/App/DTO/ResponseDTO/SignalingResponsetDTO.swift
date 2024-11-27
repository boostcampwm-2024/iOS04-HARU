import Foundation

struct SignalingResponseDTO: Encodable {
    var messageType: SignalingMessageType
    var message: Data?
    
    init(messageType: SignalingMessageType, message: Data? = nil) {
        self.messageType = messageType
        self.message = message
    }
    
    enum SignalingMessageType: String, Encodable {
        case offerSDP
        case answerSDP
        case iceCandidate
    }
}
