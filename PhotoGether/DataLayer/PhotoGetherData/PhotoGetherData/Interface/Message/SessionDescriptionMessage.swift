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
    /// 참가하려는 방의 ID
    public let roomID: String
    /// Offer를 보내는 사람의 ID
    public let offerID: String
    /// Answer를 보내는 사람의 ID
    public let answerID: String?
    
    public init(from rtcSessionDescription: RTCSessionDescription, roomID: String, offerID: String, answerID: String?) {
        self.sdp = rtcSessionDescription.sdp
        self.roomID = roomID
        self.offerID = offerID
        self.answerID = answerID
        
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
