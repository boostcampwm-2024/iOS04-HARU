import Foundation

public struct UserInfo: Identifiable {
    public var id: String
    public var nickname: String
    public var isHost: Bool
    public var viewPosition: ViewPosition
    public var roomID: String
    
    public enum ViewPosition: Int {
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
