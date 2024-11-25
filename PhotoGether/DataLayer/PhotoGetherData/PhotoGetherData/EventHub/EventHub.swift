import Combine
import Foundation
import PhotoGetherDomainInterface

final class EventQueue {
    private var queue = [EventEntity]()
    
    private let isEmptySubject = PassthroughSubject<Bool, Never>()
    
    var isEmptyPublisher: AnyPublisher<Bool, Never> {
        return isEmptySubject.eraseToAnyPublisher()
    }
    
    func push(event: EventEntity) {
        queue.append(event)
        queue.sort { $0.timeStamp > $1.timeStamp }
        isEmptySubject.send(true)
    }
    
    func popLast() -> EventEntity? {
        let popLast = queue.popLast()
        if queue.isEmpty { isEmptySubject.send(false) }
        
        return popLast
    }
}

final class EventHub {
    private let stickerEventManager = StickerEventManager()
    private var eventQueue = EventQueue() // TODO: 추후 Priority queue로 변경
    
    var stickerListPublisher: AnyPublisher<[StickerEntity], Never> {
        stickerEventManager.broadcastPublisher.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bind()
    }
    
    private func bind() {
        eventQueue.isEmptyPublisher.combineLatest(stickerEventManager.isReady)
            .filter { $0 && $1 } // MARK: (Queue에 보낼게 남아있다) && (매니저가 비어있다) -> 보낸다
            .sink { [weak self] popable, call in
                guard let currentEvent = self?.eventQueue.popLast() else {
                    debugPrint("popLast 에러")
                    return
                }
                
                switch currentEvent.payload {
                case .sticker(let stickerEntity):
                    self?.stickerEventManager.work(type: currentEvent.type, with: stickerEntity)
                case .frame(let frameEntity):
                    // TODO: FrameManager
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func push(event: EventEntity) {
        eventQueue.push(event: event)
    }
}

final class StickerEventManager {
    private let isReadySubject = CurrentValueSubject<Bool, Never>(true)
    private let broadcastSubject = PassthroughSubject<[StickerEntity], Never>()
    
    var isReady: AnyPublisher<Bool, Never> {
        return isReadySubject.eraseToAnyPublisher()
    }
    
    var broadcastPublisher: AnyPublisher<[StickerEntity], Never> {
        return broadcastSubject.eraseToAnyPublisher()
    }
    
    private var isObejctDeleted: [UUID: Bool] = [:]
    private var stickerDictionary: [UUID: StickerEntity] = [:]
    private var currenntStickerList: [StickerEntity] {
        return stickerDictionary.compactMap { $0.value }
    }
    
    func work(type: EventType, with sticker: StickerEntity) {
        isReadySubject.send(false)
        switch type {
        case .create: createEvent(by: sticker)
        case .delete: deleteEvent(by: sticker)
        case .update: updateEvent(by: sticker)
        case .unlock: unlockEvent(by: sticker)
        }
        isReadySubject.send(true)
    }
    
    private func createEvent(by sticker: StickerEntity) {
        guard isObejctDeleted[sticker.id] == nil else {
            debugPrint("Create event 실패")
            return
        }
        
        guard stickerDictionary[sticker.id] == nil else {
            debugPrint("Create event 실패")
            return
        }
        
        stickerDictionary[sticker.id] = sticker
        isObejctDeleted[sticker.id] = false
        
        // MARK: event가 아니라 전체 딕셔너리 보내기
        broadcastSubject.send(currenntStickerList)
    }
    
    private func deleteEvent(by sticker: StickerEntity) {
        guard isObejctDeleted[sticker.id] == false,            // 이미 지워진 객체를 지우려 할 때
              let oldSticker = stickerDictionary[sticker.id]   // 해당 스티커가 없을 때(전파 받기 전에 지워짐)
        else {
            // 이미 처리된 상황이기에 아무 처리를 하지 않아도 문제가 없음
            debugPrint("A/B 삭제 경쟁 상황에서 이미 처리된 삭제를 요청함")
            return
        }
        
        guard let newOwner = sticker.owner else { return }

        if oldSticker.owner == nil || oldSticker.owner == newOwner {
            // OldOwner가 nil이거나 Old,New Owner가 서로 같을 때
            stickerDictionary[sticker.id] = nil
            isObejctDeleted[sticker.id] = true
            
            broadcastSubject.send(currenntStickerList)
        }
    }
    
    private func updateEvent(by sticker: StickerEntity) {
        guard isObejctDeleted[sticker.id] == false,            // 이미 지워진 객체를 업데이트 하려 할 때
              let oldSticker = stickerDictionary[sticker.id]   // 해당 스티커가 없을 때(전파 받기 전에 지워짐)
        else {
            // 이미 처리된 상황이기에 아무 처리를 하지 않아도 문제가 없음
            debugPrint("A/B 경쟁 상황에서 이미 삭제된 객체의 업데이트를 요청함")
            return
        }
        
        guard let newOwner = sticker.owner else { return }

        if oldSticker.owner == nil || oldSticker.owner == newOwner {
            // OldOwner가 nil이거나 Old,New Owner가 서로 같을 때
            stickerDictionary[sticker.id] = sticker

            broadcastSubject.send(currenntStickerList)
        }
    }
    
    private func unlockEvent(by sticker: StickerEntity) {
        guard isObejctDeleted[sticker.id] == false,
              let oldSticker = stickerDictionary[sticker.id]
        else {
            // 이미 처리된 상황이기에 아무 처리를 하지 않아도 문제가 없음
            debugPrint("A/B 경쟁 상황에서 이미 삭제된 객체의 언락을 요청함")
            return
        }
        
        if oldSticker.owner == sticker.owner {
            var newSticker = stickerDictionary[sticker.id]
            newSticker?.updateOwner(to: nil)
            
            stickerDictionary[sticker.id] = newSticker
            broadcastSubject.send(currenntStickerList)
        }
    }
}
