import Foundation
import PhotoGetherDomainInterface

public struct CreateRoomResponseMessage: Decodable {
    let roomID: String
    let userID: String
    
    public func toEntity() -> RoomOwnerEntity {
        RoomOwnerEntity(roomID: self.roomID, userID: self.userID)
    }
}
