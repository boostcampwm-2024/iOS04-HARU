import Foundation
import WebRTC

public enum SdpType: String, Codable {
    case offer, prAnswer, answer, rollback
    
    public var rtcSdpType: RTCSdpType {
        switch self {
        case .offer:    return .offer
        case .answer:   return .answer
        case .prAnswer: return .prAnswer
        case .rollback: return .rollback
        }
    }
}

public struct SessionDescriptionMessage: Codable {
    public let sdp: String
    public let type: SdpType
    public let userID: String // MARK: Offer를 보내는 사람의 ID
    public let roomID: String // MARK: 참가하려는 방의 ID
    
    public init(from rtcSessionDescription: RTCSessionDescription, userID: String, roomID: String) {
        self.sdp = rtcSessionDescription.sdp
        self.userID = userID
        self.roomID = roomID
        
        switch rtcSessionDescription.type {
        case .offer:    self.type = .offer
        case .prAnswer: self.type = .prAnswer
        case .answer:   self.type = .answer
        case .rollback: self.type = .rollback
        @unknown default:
            fatalError("Unknown RTCSessionDescription type: \(rtcSessionDescription.type.rawValue)")
        }
    }
    
    public var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: self.type.rtcSdpType, sdp: self.sdp)
    }
}
