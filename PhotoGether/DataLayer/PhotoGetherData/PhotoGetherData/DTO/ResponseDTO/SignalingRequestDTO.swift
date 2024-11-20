import Foundation
import PhotoGetherNetwork

struct SignalingRequestDTO: WebSocketRequestable {
    var type: SignalingMessageType
    var message: Data?
    
    init(type: SignalingMessageType = .signaling, body: Data? = nil) {
        self.type = type
    }
    
    enum SignalingMessageType: String, Encodable {
        case signaling
    }
}
