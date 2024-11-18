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
        case .delete: deleteEvent(by: event)
        case .update: updateEvent(to: event)
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
    
    private func deleteEvent(by event: EventEntity) {
        guard isObejctDeleted[event.entity.id] == false else {
            // TODO: 실패한 경우를 대비한 return이 필요
            return
        }
        
        guard let oldSticker = stickerDictionary[event.entity.id] else {
            // TODO: 실패한 경우를 대비한 return이 필요
            return
        }
        
        // MARK: 이건 말도 안됨
        guard let newOwner = event.entity.owner else { return }
        
        // MARK: Old, NewOwner가 nil이 아닐 때
        if let oldOwner = oldSticker.owner {
            if oldOwner == newOwner {
                // MARK: Old,New Owner가 서로 같을 때
                stickerDictionary[event.entity.id] = nil
                isObejctDeleted[event.entity.id] = true
                
                return
            } else {
                // MARK: Old,New Owner가 서로 다를 때
                // TODO: 그냥 적용 못할 때 -> oldSticker를 전파 해줘야된다.
                
                return
            }
        }
        // MARK: OldOwner가 nil일 때
        else {
            stickerDictionary[event.entity.id] = nil
            isObejctDeleted[event.entity.id] = true
        }
    }
    
    private func updateEvent(to event: EventEntity) {
        guard isObejctDeleted[event.entity.id] == false else {
            // TODO: 실패한 경우를 대비한 return이 필요
            return
        }
        guard let oldSticker = stickerDictionary[event.entity.id] else {
            // TODO: 실패한 경우를 대비한 return이 필요
            return
        }
        
        // MARK: 이건 말도 안됨
        guard let newOwner = event.entity.owner else { return }
        
        // MARK: Old, NewOwner가 nil이 아닐 때
        if let oldOwner = oldSticker.owner {
            if oldOwner == newOwner {
                // MARK: Old,New Owner가 서로 같을 때
                stickerDictionary[event.entity.id] = event.entity
                
                return
            } else {
                // MARK: Old,New Owner가 서로 다를 때
                // TODO: 그냥 적용 못할 때 -> oldSticker를 전파 해줘야된다.
                
                return
            }
        }
        // MARK: OldOwner가 nil일 때
        else {
            stickerDictionary[event.entity.id] = event.entity
        }
    }
}
