import Foundation

public struct EventEntity: Equatable, Codable {
    public static func == (lhs: EventEntity, rhs: EventEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    private(set) var id: UUID
    public let type: EventType
    public let timeStamp: Date
    public let entity: StickerEntity
    
    public init(
        id: UUID = UUID(),
        type: EventType,
        timeStamp: Date,
        entity: StickerEntity
    ) {
        self.id = id
        self.type = type
        self.timeStamp = timeStamp
        self.entity = entity
    }
}

public enum EventType: Codable {
    case create, update, delete, unlock
}

extension EventEntity {
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
    public static func decode(from data: Data) throws -> EventEntity {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(EventEntity.self, from: data)
    }
}
