import Foundation

struct StickerEntity: Equatable {
    static func == (lhs: StickerEntity, rhs: StickerEntity) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: UUID
    let image: String
    let point: CGPoint
    let size: CGSize
    let scale: CGFloat
    let owner: String
    let latestUpdated: Date
}
