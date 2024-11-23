import Foundation

struct SignalingRequestDTO: Decodable {
    var messageType: SignalingMessageType
    var message: Data?
    
    init(messageType: SignalingMessageType = .signaling, message: Data? = nil) {
        self.messageType = messageType
        self.message = message
    }
    
    enum SignalingMessageType: String, Decodable {
        case signaling
    }
}
