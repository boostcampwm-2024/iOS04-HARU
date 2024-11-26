import Foundation
import PhotoGetherDomainInterface

public struct JoinRoomResponseMessage: Decodable {
    public let userID: String
    public let clientsID: [String]
    
    public init(userID: String, clientsID: [String]) {
        self.userID = userID
        self.clientsID = clientsID
    }
    
    public func toEntity() -> JoinRoomEntity {
        JoinRoomEntity(userID: self.userID, clientsID: self.clientsID)
    }
}
