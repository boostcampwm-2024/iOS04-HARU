import Foundation
import WebRTC

public struct IceCandidateMessage: Codable {
    public let sdp: String
    public let sdpMLineIndex: Int32
    public let sdpMid: String?
    /// 받는 사람의 ID
    public let receiverID: String
    /// 보내는 사람의 ID
    public let senderID: String
    /// 참가하려는 방의 ID
    public let roomID: String
    
    public init(
        from iceCandidate: RTCIceCandidate,
        receiverID: String,
        senderID: String,
        roomID: String
    ) {
        self.sdpMLineIndex = iceCandidate.sdpMLineIndex
        self.sdpMid = iceCandidate.sdpMid
        self.sdp = iceCandidate.sdp
        self.receiverID = receiverID
        self.senderID = senderID
        self.roomID = roomID
    }
    
    public var rtcIceCandidate: RTCIceCandidate {
        return RTCIceCandidate(sdp: self.sdp, sdpMLineIndex: self.sdpMLineIndex, sdpMid: self.sdpMid)
    }
}
