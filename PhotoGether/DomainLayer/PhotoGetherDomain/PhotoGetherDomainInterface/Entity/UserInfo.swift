import Foundation

public struct UserInfo: Identifiable, Equatable, Codable {
    public static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id: String
    public var nickname: String
    public var isHost: Bool
    public var viewPosition: ViewPosition
    public var roomID: String
    
    public enum ViewPosition: Int, Codable {
        case topLeading
        case bottomTrailing
        case topTrailing
        case bottomLeading
    }
    
    public init(
        id: String,
        nickname: String,
        isHost: Bool,
        viewPosition: ViewPosition,
        roomID: String
    ) {
        self.id = id
        self.nickname = nickname
        self.isHost = isHost
        self.viewPosition = viewPosition
        self.roomID = roomID
    }
}
