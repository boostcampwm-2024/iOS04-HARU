import Foundation

package struct IceCandidateMessage: Codable {
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String?
    let receiverID: String // MARK: 받는 사람의 ID
    let senderID: String // MARK: 보내는 사람의 ID
    let roomID: String // MARK: 참가하려는 방의 ID
    
    package init(sdp: String, sdpMLineIndex: Int32, sdpMid: String?, receiverID: String, senderID: String, roomID: String) {
        self.sdp = sdp
        self.sdpMLineIndex = sdpMLineIndex
        self.sdpMid = sdpMid
        self.receiverID = receiverID
        self.senderID = senderID
        self.roomID = roomID
    }
}
