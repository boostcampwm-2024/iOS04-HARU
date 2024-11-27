import Foundation

public struct UserInfo: Identifiable {
    public var id: String
    public var nickname: String
    public var isHost: Bool
    public var viewPosition: ViewPosition
    
    public enum ViewPosition: Int {
        case topLeading
        case topTrailing
        case bottomLeading
        case bottomTrailing
    }
    
    public init(
        id: String,
        nickname: String,
        isHost: Bool,
        viewPosition: ViewPosition
    ) {
        self.id = id
        self.nickname = nickname
        self.isHost = isHost
        self.viewPosition = viewPosition
    }
}
