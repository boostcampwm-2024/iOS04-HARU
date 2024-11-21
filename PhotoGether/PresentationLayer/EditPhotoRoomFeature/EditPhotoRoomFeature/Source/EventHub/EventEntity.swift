import Foundation

struct EventEntity: Equatable {
    static func == (lhs: EventEntity, rhs: EventEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = UUID()
    let type: EventType
    let timeStamp: Date
    let entity: StickerEntity
}

enum EventType {
    case create, update, delete
}
