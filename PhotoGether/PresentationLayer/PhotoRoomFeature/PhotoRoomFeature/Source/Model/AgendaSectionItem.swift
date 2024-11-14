import Foundation

public struct ParticipantsSectionItem: Hashable, Equatable {
    public private(set) var nickname: String
    public let videoID: Int
    private let identifier = UUID()

    public init(videoID: Int, nickname: String) {
        self.videoID = videoID
        self.nickname = nickname
    }
    
    public mutating func setNickname(_ nickname: String) {
        self.nickname = nickname
    }
}

public extension ParticipantsSectionItem {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: ParticipantsSectionItem, rhs: ParticipantsSectionItem) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
