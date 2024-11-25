import Foundation

public struct EventEntity: Equatable, Codable {
    public static func == (lhs: EventEntity, rhs: EventEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    private(set) var id: UUID
    public let type: EventType
    public let timeStamp: Date
    public let payload: EventPayload
    
    public init(
        id: UUID = UUID(),
        type: EventType,
        timeStamp: Date,
        payload: EventPayload
    ) {
        self.id = id
        self.type = type
        self.timeStamp = timeStamp
        self.payload = payload
    }
}

@frozen
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

@frozen
public enum EventPayload: Codable {
    case sticker(StickerEntity)
    case frame(FrameEntity)
    case stickerList([StickerEntity]) // 새로운 case 추가

    private enum EntityTypeKey: String, Codable {
        case sticker
        case frame
        case stickerList // 새로운 키 추가
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(EntityTypeKey.self, forKey: .type)
        
        switch type {
        case .sticker:
            self = .sticker(try container.decode(StickerEntity.self, forKey: .data))
        case .frame:
            self = .frame(try container.decode(FrameEntity.self, forKey: .data))
        case .stickerList: // stickerList 추가
            self = .stickerList(try container.decode([StickerEntity].self, forKey: .data))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .sticker(let stickerEntity):
            try container.encode(EntityTypeKey.sticker, forKey: .type)
            try container.encode(stickerEntity, forKey: .data)
        case .frame(let frameEntity):
            try container.encode(EntityTypeKey.frame, forKey: .type)
            try container.encode(frameEntity, forKey: .data)
        case .stickerList(let stickerList): // stickerList 인코딩 추가
            try container.encode(EntityTypeKey.stickerList, forKey: .type)
            try container.encode(stickerList, forKey: .data)
        }
    }
}
