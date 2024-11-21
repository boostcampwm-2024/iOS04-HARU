import Foundation

public struct StickerEntity: Equatable, Codable {
    public static func == (lhs: StickerEntity, rhs: StickerEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: UUID
    public let image: String
    public let frame: CGRect
    public let owner: String?
    public let latestUpdated: Date
    
    public init(
        id: UUID = UUID(),
        image: String,
        frame: CGRect,
        owner: String?,
        latestUpdated: Date
    ) {
        self.id = id
        self.image = image
        self.frame = frame
        self.owner = owner
        self.latestUpdated = latestUpdated
    }
}
