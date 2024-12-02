import Foundation
import PhotoGetherNetwork

public struct SignalingRequestDTO: WebSocketRequestable {
    public var messageType: SignalingMessageType
    public var message: Data?
    
    public init(messageType: SignalingMessageType, message: Data? = nil) {
        self.messageType = messageType
        self.message = message
    }
    
    public enum SignalingMessageType: String, Encodable {
        case offerSDP
        case answerSDP
        case iceCandidate
    }
}
