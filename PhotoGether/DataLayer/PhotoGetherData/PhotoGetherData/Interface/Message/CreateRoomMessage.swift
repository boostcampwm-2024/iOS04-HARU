import Foundation

struct CreateRoomMessage: Decodable {
    let roomID: String
    let userID: String
}
