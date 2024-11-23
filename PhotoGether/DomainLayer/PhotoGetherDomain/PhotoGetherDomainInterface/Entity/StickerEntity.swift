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
    
    enum CodingKeys: String, CodingKey {
        case id, image, frame, owner, latestUpdated
    }

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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.image = try container.decode(String.self, forKey: .image)
        self.owner = try container.decodeIfPresent(String.self, forKey: .owner) // Optional 처리
        self.latestUpdated = try container.decode(Date.self, forKey: .latestUpdated)

        let frameDict = try container.decode([String: CGFloat].self, forKey: .frame)
        guard let originX = frameDict["x"],
              let originY = frameDict["y"],
              let width = frameDict["width"],
              let height = frameDict["height"] else {
            throw DecodingError.dataCorruptedError(
                forKey: .frame,
                in: container,
                debugDescription: "Frame dictionary does not contain valid keys."
            )
        }
        self.frame = CGRect(x: originX, y: originY, width: width, height: height)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(image, forKey: .image)
        try container.encode(owner, forKey: .owner)
        try container.encode(latestUpdated, forKey: .latestUpdated)

        let frameDict = [
            "x": frame.origin.x,
            "y": frame.origin.y,
            "width": frame.size.width,
            "height": frame.size.height
        ]
        try container.encode(frameDict, forKey: .frame)
    }
}

extension Array where Element == StickerEntity {
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
}
