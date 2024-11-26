import Foundation

public struct RoomOwnerEntity {
    public let roomID: String
    public let hostID: String
    
    public init(roomID: String, hostID: String) {
        self.roomID = roomID
        self.hostID = hostID
    }
}
