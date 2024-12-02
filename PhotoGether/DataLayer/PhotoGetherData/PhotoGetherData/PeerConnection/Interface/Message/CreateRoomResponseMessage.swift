import Foundation
import PhotoGetherDomainInterface

public struct CreateRoomResponseMessage: Decodable {
    let roomID: String
    let hostID: String
    
    public func toEntity() -> RoomOwnerEntity {
        RoomOwnerEntity(roomID: self.roomID, hostID: self.hostID)
    }
}
