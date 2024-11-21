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

import Foundation

extension Array where Element == StickerEntity {
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
    public static func decode(_ data: Data) throws -> [StickerEntity] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([StickerEntity].self, from: data)
    }
}
