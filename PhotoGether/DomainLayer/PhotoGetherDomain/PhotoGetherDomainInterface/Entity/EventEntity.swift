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
    case create, update, delete
}
