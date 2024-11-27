import Combine
import Foundation
import PhotoGetherDomainInterface
import UIKit

public final class EditPhotoRoomGuestViewModel {
    enum Input {
        case stickerButtonDidTap
        case frameButtonDidTap
        case createSticker(StickerEntity)
        case deleteSticker(UUID)
        case stickerViewDidTap(UUID)
    }
    
    enum Output {
        case stickerList([StickerEntity])
        case frameImage(image: UIImage)
        case stickerBottomSheetPresent
    }
    
    private let frameImageGenerator: FrameImageGenerator
    private let receiveStickerListUseCase: ReceiveStickerListUseCase
    private let receiveFrameUseCase: ReceiveFrameUseCase
    private let sendStickerToRepositoryUseCase: SendStickerToRepositoryUseCase
    private let sendFrameToRepositoryUseCase: SendFrameToRepositoryUseCase
    
    let owner = "GUEST" + UUID().uuidString.prefix(4) // MARK: 임시 값(추후 ConnectionClient에서 받아옴)
    
    private let stickerListSubject = CurrentValueSubject<[StickerEntity], Never>([])
    private let frameTypeSubject = CurrentValueSubject<FrameType, Never>(Constants.defaultFrameType)
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init(
        frameImageGenerator: FrameImageGenerator,
        receiveStickerListUseCase: ReceiveStickerListUseCase,
        receiveFrameUseCase: ReceiveFrameUseCase,
        sendStickerToRepositoryUseCase: SendStickerToRepositoryUseCase,
        sendFrameToRepositoryUseCase: SendFrameToRepositoryUseCase
    ) {
        self.frameImageGenerator = frameImageGenerator
        self.receiveStickerListUseCase = receiveStickerListUseCase
        self.receiveFrameUseCase = receiveFrameUseCase
        self.sendStickerToRepositoryUseCase = sendStickerToRepositoryUseCase
        self.sendFrameToRepositoryUseCase = sendFrameToRepositoryUseCase
        bind()
    }
    
    func configureDefaultState() {
        let defaultFrameType = Constants.defaultFrameType
        mutateFrameTypeLocal(with: defaultFrameType)
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
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}

// MARK: Sticker 관련
extension EditPhotoRoomGuestViewModel {
    private func handleCreateSticker(sticker: StickerEntity) {
        mutateStickerLocal(sticker: sticker)
        mutateStickerEventHub(type: .create, with: sticker)
    }
    
    private func handleDeleteSticker(with stickerID: UUID) {
        let stickerList = stickerListSubject.value
        guard let sticker = stickerList.find(id: stickerID) else { return }
        
        mutateStickerEventHub(type: .delete, with: sticker)
    }
    
    private func mutateStickerLocal(sticker: StickerEntity) {
        var stickerList = stickerListSubject.value
        stickerList.append(sticker)
        stickerListSubject.send(stickerList)
    }
    
    private func mutateStickerListLocal(stickerList: [StickerEntity]) {
        stickerListSubject.send(stickerList)
    }
    
    private func mutateStickerEventHub(type: EventType, with sticker: StickerEntity) {
        sendStickerToRepositoryUseCase.execute(type: type, sticker: sticker)
    }
    
    private func handleStickerViewDidTap(with stickerID: UUID) {
        // MARK: 선택할 수 있는 객체인지 확인함
        guard canInteractWithSticker(id: stickerID) else { return }
        
        // MARK: 필요시 이전 스티커를 unlock하고 반영함
        unlockPreviousSticker()
        
        // MARK: Tap한 스티커를 lock하고 반영한다.
        lockTappedSticker(id: stickerID)
    }
    
    private func canInteractWithSticker(id: UUID) -> Bool {
        let stickerList = stickerListSubject.value
        
        return stickerList.isOwned(id: id, owner: owner)
    }
    
    private func unlockPreviousSticker() {
        var stickerList = stickerListSubject.value
        
        if let previousSticker = stickerList.lockedSticker(by: owner) {
            stickerList.unlock(by: owner)
            mutateStickerEventHub(type: .unlock, with: previousSticker)
        }
    }
    
    private func lockTappedSticker(id: UUID) {
        var stickerList = stickerListSubject.value
        
        if let tappedSticker = stickerList.lock(by: id, owner: owner) {
            mutateStickerListLocal(stickerList: stickerList)
            mutateStickerEventHub(type: .update, with: tappedSticker)
        }
    }

    private func presentStickerBottomSheet() {
        output.send(.stickerBottomSheetPresent)
    }
}

// MARK: Frame 관련
extension EditPhotoRoomGuestViewModel {
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
        let frameEntity = FrameEntity(frameType: frameType, owner: owner, latestUpdated: Date())
        sendFrameToRepositoryUseCase.execute(type: .update, frame: frameEntity)
    }

    private func applyFrameImage(with frameType: FrameType) {
        frameImageGenerator.changeFrame(to: frameType)
        let frameImage = frameImageGenerator.generate()

        output.send(.frameImage(image: frameImage))
    }
}

private extension EditPhotoRoomGuestViewModel {
    enum Constants {
        static let defaultFrameType: FrameType = .defaultBlack
    }
}
