import Foundation

final class EventHub {
    // TODO: 추후 Priority queue로 변경
    var queue: [EventEntity] = []
    let manager = EventManager()
    
    func push(event: EventEntity) { queue.append(event) }
    
    func checkMangerIsFree() {
        if manager.currentEvent == nil {
            manager.work(event: queue.popLast()!)
        }
    }
}


final class EventManager {
    var currentEvent: EventEntity? = nil
    var isObejctDeleted: [UUID: Bool] = [:]
    var stickerDictionary: [UUID: StickerEntity] = [:]
    
    func work(event: EventEntity) {
        switch event.type {
        case .create: createEvent(by: event)
        case .delete: break
        case .update: break
        }
    }
    
    private func createEvent(by event: EventEntity) {
        guard isObejctDeleted[event.entity.id] == nil else {
            // TODO: 실패한 경우를 대비한 return이 필요
            return
        }
        guard stickerDictionary[event.entity.id] == nil else {
            // TODO: 실패한 경우를 대비한 return이 필요
            return
        }
        
        stickerDictionary[event.entity.id] = event.entity
        isObejctDeleted[event.entity.id] = false
    }
}
