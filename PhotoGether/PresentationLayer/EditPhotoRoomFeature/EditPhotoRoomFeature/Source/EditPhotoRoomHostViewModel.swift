import Combine
import Foundation
import PhotoGetherDomainInterface
import UIKit

public final class EditPhotoRoomHostViewModel {
    enum Input {
        case initialState
        case stickerButtonDidTap
        case frameButtonDidTap
        case createSticker(StickerEntity)
        case deleteSticker(UUID)
        case dragSticker(StickerEntity, PanGestureState)
        case resizeSticker(StickerEntity, PanGestureState)
        case stickerViewDidTap(UUID)
        case micButtonDidTap
    }
    
    enum Output {
        case stickerList([StickerEntity])
        case frameImage(image: UIImage)
        case presentStickerBottomSheet
        case voiceInputState(Bool)
    }
    
    private var frameImageGenerator: FrameImageGenerator?
    private let receiveStickerListUseCase: ReceiveStickerListUseCase
    private let receiveFrameUseCase: ReceiveFrameUseCase
    private let sendStickerToRepositoryUseCase: SendStickerToRepositoryUseCase
    private let sendFrameToRepositoryUseCase: SendFrameToRepositoryUseCase
    private let toggleLocalMicStateUseCase: ToggleLocalMicStateUseCase
    private let getVoiceInputStateUseCase: GetVoiceInputStateUseCase
    
    private(set) var userInfo: UserInfo!
    
    private let stickerListSubject = CurrentValueSubject<[StickerEntity], Never>([])
    private let frameTypeSubject = CurrentValueSubject<FrameType, Never>(Constants.defaultFrameType)
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init(
        receiveStickerListUseCase: ReceiveStickerListUseCase,
        receiveFrameUseCase: ReceiveFrameUseCase,
        sendStickerToRepositoryUseCase: SendStickerToRepositoryUseCase,
        sendFrameToRepositoryUseCase: SendFrameToRepositoryUseCase,
        toggleLocalMicStateUseCase: ToggleLocalMicStateUseCase,
        getVoiceInputStateUseCase: GetVoiceInputStateUseCase
    ) {
        self.receiveStickerListUseCase = receiveStickerListUseCase
        self.receiveFrameUseCase = receiveFrameUseCase
        self.sendStickerToRepositoryUseCase = sendStickerToRepositoryUseCase
        self.sendFrameToRepositoryUseCase = sendFrameToRepositoryUseCase
        self.toggleLocalMicStateUseCase = toggleLocalMicStateUseCase
        self.getVoiceInputStateUseCase = getVoiceInputStateUseCase
        bind()
    }
    
    private func configureInitialState() {
        let defaultFrameType = Constants.defaultFrameType
        mutateFrameTypeLocal(with: defaultFrameType)
        mutateFrameTypeEventHub(with: defaultFrameType)
    }
    
    private func bind() {
        stickerListSubject
            .sink { [weak self] list in
                self?.output.send(.stickerList(list))
            }
            .store(in: &cancellables)
        
        frameTypeSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] frameType in
                self?.applyFrameImage(with: frameType)
            }
            .store(in: &cancellables)
        
        receiveStickerListUseCase.execute()
            .sink { [weak self] receivedStickerList in
                self?.mutateStickerListLocal(stickerList: receivedStickerList)
            }
            .store(in: &cancellables)
        
        receiveFrameUseCase.execute()
            .sink { [weak self] receivedFrame in
                let receivedFrameType = receivedFrame.frameType
                self?.mutateFrameTypeLocal(with: receivedFrameType)
            }
            .store(in: &cancellables)
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .initialState:
                self?.configureInitialState()
            case .stickerButtonDidTap:
                self?.presentStickerBottomSheet()
            case .frameButtonDidTap:
                self?.toggleFrameType()
            case .createSticker(let sticker):
                self?.handleCreateSticker(sticker: sticker)
            case .deleteSticker(let stickerID):
                self?.handleDeleteSticker(with: stickerID)
            case .stickerViewDidTap(let stickerID):
                self?.handleStickerViewDidTap(with: stickerID)
            case .dragSticker(let sticker, let dragState):
                self?.handleDragSticker(sticker: sticker, state: dragState)
            case .resizeSticker(let sticker, let resizeState):
                self?.handleResizeSticker(sticker: sticker, state: resizeState)
            case .micButtonDidTap:
                self?.handleMicButtonDidTap()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    func fetchLocalVoiceInputState() -> Bool {
        getVoiceInputStateUseCase.execute()
    }
}

// MARK: Sticker
extension EditPhotoRoomHostViewModel {
    enum PanGestureState {
        case began
        case changed
        case ended
    }
    
    private func mutateStickerLocal(type: EventType, sticker: StickerEntity) {
        switch type {
        case .create:
            var stickerList = stickerListSubject.value
            stickerList.append(sticker)
            stickerListSubject.send(stickerList)
        case .delete: break
        case .update:
            let stickerList = stickerListSubject.value
            stickerListSubject.send(stickerList)
        case .unlock: break
        }
    }
    
    private func mutateStickerListLocal(stickerList: [StickerEntity]) {
        stickerListSubject.send(stickerList)
    }
    
    private func mutateStickerEventHub(type: EventType, with sticker: StickerEntity) {
        sendStickerToRepositoryUseCase.execute(type: type, sticker: sticker)
    }
    
    private func canInteractWithSticker(id: UUID) -> Bool {
        let stickerList = stickerListSubject.value
        
        return stickerList.isOwned(id: id, owner: userInfo)
    }
    
    private func unlockPreviousSticker(stickerId: UUID) {
        var stickerList = stickerListSubject.value
        
        if let previousSticker = stickerList.lockedSticker(by: userInfo),
           stickerId != previousSticker.id {
            stickerList.unlock(by: userInfo)
            mutateStickerEventHub(type: .unlock, with: previousSticker)
        }
    }
    
    private func lockTappedSticker(id: UUID) {
        var stickerList = stickerListSubject.value
        
        if let tappedSticker = stickerList.lock(by: id, owner: userInfo) {
            mutateStickerListLocal(stickerList: stickerList)
            mutateStickerEventHub(type: .update, with: tappedSticker)
        }
    }
}

// MARK: Sticker Drag
extension EditPhotoRoomHostViewModel {
    private func handleDragSticker(sticker: StickerEntity, state: PanGestureState) {
        switch state {
        case .began:
            handleDragBegan(sticker: sticker)
        case .changed:
            handleDragChanged(sticker: sticker)
        case .ended:
            handleDragEnded(sticker: sticker)
        }
    }
    
    private func handleDragBegan(sticker: StickerEntity) {
        guard canInteractWithSticker(id: sticker.id) else { return }
        
        unlockPreviousSticker(stickerId: sticker.id)
        lockTappedSticker(id: sticker.id)
        mutateStickerEventHub(type: .update, with: sticker)
    }
    
    private func handleDragChanged(sticker: StickerEntity) {
        guard canInteractWithSticker(id: sticker.id) else { return }
        
        mutateStickerEventHub(type: .update, with: sticker)
    }
    
    private func handleDragEnded(sticker: StickerEntity) {
        mutateStickerLocal(type: .update, sticker: sticker)
        
        guard canInteractWithSticker(id: sticker.id) else { return }
        
        mutateStickerEventHub(type: .update, with: sticker)
    }
}

// MARK: Sticker Resize
extension EditPhotoRoomHostViewModel {
    private func handleResizeSticker(sticker: StickerEntity, state: PanGestureState) {
        switch state {
        case .began:
            handleResizeBegan(sticker: sticker)
        case .changed:
            handleResizeChanged(sticker: sticker)
        case .ended:
            handleResizeEnded(sticker: sticker)
        }
    }
    
    private func handleResizeBegan(sticker: StickerEntity) {
        guard canInteractWithSticker(id: sticker.id) else { return }
        
        mutateStickerEventHub(type: .update, with: sticker)
    }
    
    private func handleResizeChanged(sticker: StickerEntity) {
        guard canInteractWithSticker(id: sticker.id) else { return }
        
        mutateStickerEventHub(type: .update, with: sticker)
    }
    
    private func handleResizeEnded(sticker: StickerEntity) {
        mutateStickerLocal(type: .update, sticker: sticker)
        
        guard canInteractWithSticker(id: sticker.id) else { return }
        
        mutateStickerEventHub(type: .update, with: sticker)
    }
}

// MARK: Sticker Tap
extension EditPhotoRoomHostViewModel {
    private func handleStickerViewDidTap(with stickerID: UUID) {
        // MARK: 선택할 수 있는 객체인지 확인함
        guard canInteractWithSticker(id: stickerID) else { return }
        
        // MARK: 필요시 이전 스티커를 unlock하고 반영함
        unlockPreviousSticker(stickerId: stickerID)
        
        // MARK: Tap한 스티커를 lock하고 반영한다.
        lockTappedSticker(id: stickerID)
    }
}

// MARK: Sticker Create
extension EditPhotoRoomHostViewModel {
    private func handleCreateSticker(sticker: StickerEntity) {
        mutateStickerLocal(type: .create, sticker: sticker)
        mutateStickerEventHub(type: .create, with: sticker)
    }
}

// MARK: Sticker Delete
extension EditPhotoRoomHostViewModel {
    private func handleDeleteSticker(with stickerID: UUID) {
        let stickerList = stickerListSubject.value
        guard let sticker = stickerList.find(id: stickerID) else { return }
        
        mutateStickerEventHub(type: .delete, with: sticker)
    }
}

// MARK: Frame 관련
extension EditPhotoRoomHostViewModel {
    private enum Constants {
        static let defaultFrameType: FrameType = .defaultBlack
    }
    
    private func toggleFrameType() {
        let oldFrameImageType = frameTypeSubject.value
        let newFrameImageType = (oldFrameImageType == .defaultBlack)
        ? FrameType.defaultWhite
        : FrameType.defaultBlack

        mutateFrameTypeLocal(with: newFrameImageType)
        mutateFrameTypeEventHub(with: newFrameImageType)
    }

    private func mutateFrameTypeLocal(with frameType: FrameType) {
        frameTypeSubject.send(frameType)
    }

    private func mutateFrameTypeEventHub(with frameType: FrameType) {
        let frameEntity = FrameEntity(frameType: frameType, owner: userInfo, latestUpdated: Date())
        sendFrameToRepositoryUseCase.execute(type: .update, frame: frameEntity)
    }
    
    private func applyFrameImage(with frameType: FrameType) {
        frameImageGenerator?.changeFrame(to: frameType)
        guard let frameImage = frameImageGenerator?.generate() else { return }

        output.send(.frameImage(image: frameImage))
    }
    
    func setViewModel(_ frameImageGenerator: FrameImageGenerator, userInfo: UserInfo) {
        self.frameImageGenerator = frameImageGenerator
        self.userInfo = userInfo
    }
}

// MARK: Show Bottom Sheet
extension EditPhotoRoomHostViewModel {
    private func presentStickerBottomSheet() {
        output.send(.presentStickerBottomSheet)
    }
}

// MARK: Voice Input Control
extension EditPhotoRoomHostViewModel {
    private func handleMicButtonDidTap() {
        toggleLocalMicStateUseCase.execute()
            .sink { [weak self] state in
                self?.output.send(.voiceInputState(state))
            }.store(in: &cancellables)
    }
}
