import Foundation
import PhotoGetherNetwork

struct SignalingRequestDTO: WebSocketRequestable {
    var messageType: SignalingMessageType
    var message: Data?
    
    init(messageType: SignalingMessageType = .signaling, message: Data? = nil) {
        self.messageType = messageType
        self.message = message
    }
    
    enum SignalingMessageType: String, Encodable {
        case signaling
    }
}
