import Foundation
import Combine
import PhotoGetherDomainInterface

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
    
    var resultEventPublisher: AnyPublisher<[StickerEntity], Never> {
        eventManager.resultEventPublihser.eraseToAnyPublisher()
    }
    
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
    }
    
    func push(event: EventEntity) {
        eventQueue.push(event: event)
    }
}

final class EventManager {
    // MARK: 네이밍 좀 고민
    let callEventPublisher = CurrentValueSubject<Bool, Never>(true)
    let resultEventPublihser = PassthroughSubject<[StickerEntity], Never>()
    
    private var isObejctDeleted: [UUID: Bool] = [:]
    private var stickerDictionary: [UUID: StickerEntity] = [:]
    private var currenntStickerList: [StickerEntity] {
        return stickerDictionary.compactMap { $0.value }
    }
    
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
            debugPrint("Create event 실패")
            return
        }
        guard stickerDictionary[event.entity.id] == nil else {
            debugPrint("Create event 실패")
            return
        }
        
        stickerDictionary[event.entity.id] = event.entity
        isObejctDeleted[event.entity.id] = false
        
        // MARK: event가 아니라 전체 딕셔너리 보내기
        resultEventPublihser.send(currenntStickerList)
    }
    
    private func deleteEvent(by event: EventEntity) {
        guard isObejctDeleted[event.entity.id] == false,            // 이미 지워진 객체를 지우려 할 때
              let oldSticker = stickerDictionary[event.entity.id]   // 해당 스티커가 없을 때(전파 받기 전에 지워짐)
        else {
            // 이미 처리된 상황이기에 아무 처리를 하지 않아도 문제가 없음
            debugPrint("A/B 삭제 경쟁 상황에서 이미 처리된 삭제를 요청함")
            return
        }
        
        guard let newOwner = event.entity.owner else { return }

        if oldSticker.owner == nil || oldSticker.owner == newOwner {
            // OldOwner가 nil이거나 Old,New Owner가 서로 같을 때
            stickerDictionary[event.entity.id] = nil
            isObejctDeleted[event.entity.id] = true
            
            resultEventPublihser.send(currenntStickerList)
        }
    }
    
    private func updateEvent(to event: EventEntity) {
        guard isObejctDeleted[event.entity.id] == false,            // 이미 지워진 객체를 업데이트 하려 할 때
              let oldSticker = stickerDictionary[event.entity.id]   // 해당 스티커가 없을 때(전파 받기 전에 지워짐)
        else {
            // 이미 처리된 상황이기에 아무 처리를 하지 않아도 문제가 없음
            debugPrint("A/B 경쟁 상황에서 이미 삭제된 객체의 업데이트를 요청함")
            return
        }
        
        guard let newOwner = event.entity.owner else { return }

        if oldSticker.owner == nil || oldSticker.owner == newOwner {
            // OldOwner가 nil이거나 Old,New Owner가 서로 같을 때
            stickerDictionary[event.entity.id] = event.entity

            resultEventPublihser.send(currenntStickerList)
        }
    }
}
