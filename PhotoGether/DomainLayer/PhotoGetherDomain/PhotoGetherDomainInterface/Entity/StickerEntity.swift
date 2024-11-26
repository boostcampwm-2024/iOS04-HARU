import Foundation

public struct StickerEntity: Equatable, Codable {
    public static func == (lhs: StickerEntity, rhs: StickerEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: UUID
    public let image: String
    public private(set) var frame: CGRect
    public private(set) var owner: String?
    public private(set) var latestUpdated: Date
    
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
    
    public mutating func updateOwner(to owner: String?) {
        self.owner = owner
        self.latestUpdated = Date()
    }
    
    public mutating func updateFrame(to frame: CGRect) {
        self.frame = frame
        self.latestUpdated = Date()
    }
}

extension Array where Element == StickerEntity {
    subscript(safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
    public func find(id: UUID) -> StickerEntity? {
        if let index = firstIndex(where: { $0.id == id }) {
            return self[safe: index]
        }
        return nil
    }

    public func isOwned(id: UUID, owner: String) -> Bool {
        guard let target = first(where: { $0.id == id }) else { return false }
        return target.owner == nil || target.owner == owner
    }
    
    public mutating func lockedSticker(by owner: String) -> StickerEntity? {
        if let index = firstIndex(where: { $0.owner == owner }) {
            return self[safe: index]
        }
        return nil
    }
    
    public mutating func unlock(by owner: String) {
        if let index = firstIndex(where: { $0.owner == owner }) {
            self[index].updateOwner(to: nil)
        }
    }

    public mutating func lock(by id: UUID, owner: String) -> StickerEntity? {
        if let index = firstIndex(where: { $0.id == id }) {
            self[index].updateOwner(to: owner)
            return self[index]
        }
        return nil
    }
}
