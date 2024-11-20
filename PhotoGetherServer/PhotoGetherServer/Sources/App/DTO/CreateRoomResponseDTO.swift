import Foundation

package struct CreateRoomResponseDTO: Encodable {
    let roomID: String
    let userID: String
    
    func toData(_ encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}
