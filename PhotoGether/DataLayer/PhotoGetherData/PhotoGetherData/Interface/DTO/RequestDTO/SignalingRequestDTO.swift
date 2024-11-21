import Foundation
import PhotoGetherNetwork

struct SignalingRequestDTO: WebSocketRequestable {
    var messageType: SignalingMessageType
    var message: Data?
    
    init(messageType: SignalingMessageType = .signaling, message: Data? = nil) {
        self.messageType = messageType
    }
    
    enum SignalingMessageType: String, Encodable {
        case signaling
    }
}
