import UIKit

public struct ParticipantsSectionItem {
    public let position: Position
    public private(set) var nickname: String
    public private(set) weak var videoView: UIView?
    
    public init(position: Position, nickname: String, videoView: UIView? = nil) {
        self.position = position
        self.nickname = nickname
        self.videoView = videoView
    }
    
    public mutating func setNickname(_ nickname: String) {
        self.nickname = nickname
    }
    
    public mutating func setVideoView(_ videoView: UIView) {
        self.videoView = videoView
    }
    
    public enum Position {
        case host, guest1, guest2, guest3
    }
}

extension ParticipantsSectionItem: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
    }

    public static func == (lhs: ParticipantsSectionItem, rhs: ParticipantsSectionItem) -> Bool {
        lhs.position == rhs.position
    }
}
