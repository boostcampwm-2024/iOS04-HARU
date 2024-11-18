import Foundation
import Combine

final class EventQueue {
    private var queue = [EventEntity]()
    
    let popablePublisher = PassthroughSubject<Bool, Never>()
    
    func push(event: EventEntity) {
        queue.append(event)
        queue.sort { $0.timeStamp > $1.timeStamp }
        popablePublisher.send(true)
    }
    
    func popLast() -> EventEntity? {
        let popLast = queue.popLast()
        return popLast
    }
}

final class EventHub {
    private let eventManager = EventManager()
    private var eventQueue = EventQueue() // TODO: 추후 Priority queue로 변경
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bind()
    }
    
    private func bind() {
        eventQueue.popablePublisher.combineLatest(eventManager.callEventPublisher)
            .filter { $0 && $1 } // MARK: (Queue에 보낼게 남아있다) && (매니저가 비어있다) -> 보낸다
            .sink { [weak self] popable, call in
                guard let currentEvent = self?.eventQueue.popLast() else {
                    debugPrint("popLast 에러")
                    return
                }
                self?.eventManager.work(event: currentEvent)
            }
            .store(in: &cancellables)
        
        eventManager.resultEventPublihser
            .sink { eventEntity in
                // MARK: ConnectionClient에게 보내기
            }
            .store(in: &cancellables)
    }
    
    func push(event: EventEntity) {
        eventQueue.push(event: event)
    }
}

final class EventManager {
    // MARK: 네이밍 좀 고민
    let callEventPublisher = CurrentValueSubject<Bool, Never>(true)
    let resultEventPublihser = PassthroughSubject<EventEntity, Never>()
    
    private var isObejctDeleted: [UUID: Bool] = [:]
    private var stickerDictionary: [UUID: StickerEntity] = [:]
    
    func work(event: EventEntity) {
        callEventPublisher.send(false)
        switch event.type {
        case .create: createEvent(by: event)
        case .delete: deleteEvent(by: event)
        case .update: updateEvent(to: event)
        }
        callEventPublisher.send(true)
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
