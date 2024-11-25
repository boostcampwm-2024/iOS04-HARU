import Foundation

public struct JoinRoomEntity {
    public let userID: String
    public let clientsID: [String]
    
    public init(userID: String, clientsID: [String]) {
        self.userID = userID
        self.clientsID = clientsID
    }
}
