import UIKit

public struct ParticipantsSectionItem {
    public private(set) var nickname: String
    public let videoID: Int
    public private(set) weak var videoView: UIView?
    private let identifier = UUID()

    public init(videoID: Int, nickname: String) {
        self.videoID = videoID
        self.nickname = nickname
    }
    
    public mutating func setNickname(_ nickname: String) {
        self.nickname = nickname
    }
    
    public mutating func setVideoView(_ videoView: UIView) {
        self.videoView = videoView
    }
}

extension ParticipantsSectionItem: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    public static func == (lhs: ParticipantsSectionItem, rhs: ParticipantsSectionItem) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
