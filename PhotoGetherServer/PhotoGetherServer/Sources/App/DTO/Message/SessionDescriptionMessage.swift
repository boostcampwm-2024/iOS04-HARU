import Foundation
package enum SdpType: String, Codable {
    case offer, prAnswer, answer, rollback
}

package struct SessionDescriptionMessage: Codable {
    let sdp: String
    let type: SdpType
    let userID: String // MARK: Offer를 보내는 사람의 ID
    let roomID: String // MARK: 참가하려는 방의 ID
    
    package init(sdp: String, type: SdpType, userID: String, roomID: String) {
        self.sdp = sdp
        self.type = type
        self.userID = userID
        self.roomID = roomID
    }
}
