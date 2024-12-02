import Foundation

public struct FrameEntity: Equatable, Codable {
    public static func == (lhs: FrameEntity, rhs: FrameEntity) -> Bool {
        return lhs.frameType == rhs.frameType
    }
    
    public let id: UUID
    public let frameType: FrameType
    public private(set) var owner: UserInfo?
    public private(set) var latestUpdated: Date
    
    public init(
        id: UUID = UUID(),
        frameType: FrameType,
        owner: UserInfo?,
        latestUpdated: Date
    ) {
        self.id = id
        self.frameType = frameType
        self.owner = owner
        self.latestUpdated = latestUpdated
    }
}

@frozen
public enum FrameType: Codable {
    case defaultBlack
    case defaultWhite
}
