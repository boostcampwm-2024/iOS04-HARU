import Foundation
package enum SdpType: String, Codable {
    case offer, prAnswer, answer, rollback
}

package struct SessionDescriptionMessage: Codable {
    let sdp: String
    let type: SdpType
    let roomID: String // MARK: 참가하려는 방의 ID
    let offerID: String // MARK: Offer를 보내는 사람의 ID
    var answerID: String? // MARK: Anwer를 보내는 사람의 ID
    
    package init(
        sdp: String,
        type: SdpType,
        offerID: String,
        roomID: String,
        answerID: String? = nil
    ) {
        self.sdp = sdp
        self.type = type
        self.roomID = roomID
        self.offerID = offerID
        self.answerID = answerID
    }
}
