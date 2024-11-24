import Combine
import Foundation
import PhotoGetherDomainInterface
import UIKit

public final class EditPhotoRoomGuestViewModel {
    enum Input {
        case stickerButtonDidTap
        case frameButtonDidTap
        case createSticker(StickerEntity)
        case stickerViewDidTap(UUID)
    }
    
    enum Output {
        case emojiEntity(entity: EmojiEntity)
        case stickerObjectList([StickerEntity])
        case frameImage(image: UIImage)
    }
    
    private let frameImageGenerator: FrameImageGenerator
    private let fetchEmojiListUseCase: FetchEmojiListUseCase
    private let receiveStickerListUseCase: ReceiveStickerListUseCase
    private let sendStickerToRepositoryUseCase: SendStickerToRepositoryUseCase
    
    private var emojiList: [EmojiEntity] = [] // MARK: 추후 삭제 예정
    private let owner = "GUEST" + UUID().uuidString.prefix(4) // MARK: 임시 값(추후 ConnectionClient에서 받아옴)
    
    private let stickerObjectListSubject = CurrentValueSubject<[StickerEntity], Never>([])
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init(
        frameImageGenerator: FrameImageGenerator,
        fetchEmojiListUseCase: FetchEmojiListUseCase,
        receiveStickerListUseCase: ReceiveStickerListUseCase,
        sendStickerToRepositoryUseCase: SendStickerToRepositoryUseCase
    ) {
        self.frameImageGenerator = frameImageGenerator
        self.fetchEmojiListUseCase = fetchEmojiListUseCase
        self.receiveStickerListUseCase = receiveStickerListUseCase
        self.sendStickerToRepositoryUseCase = sendStickerToRepositoryUseCase
        bind()
    }
    
    private func bind() {
        fetchEmojiList()
        
        stickerObjectListSubject
            .sink { [weak self] list in
                self?.output.send(.stickerObjectList(list))
            }
            .store(in: &cancellables)
        
        receiveStickerListUseCase.execute()
            .sink { [weak self] receivedStickerList in
                self?.stickerObjectListSubject.send(receivedStickerList)
            }
            .store(in: &cancellables)
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .stickerButtonDidTap:
                self?.sendEmoji()
            case .createSticker(let sticker):
                self?.appendSticker(with: sticker)
                self?.sendToRepository(type: .create, with: sticker)
            case .frameButtonDidTap:
                self?.toggleFrameImage()
            case .stickerViewDidTap(let stickerID):
                self?.handleStickerViewDidTap(with: stickerID)
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func toggleFrameImage() {
        let currentFrameImageType = frameImageGenerator.frameType
        var newFrameImageType: FrameType
        switch currentFrameImageType {
        case .defaultBlack:
            newFrameImageType = .defaultWhite
        case .defaultWhite:
            newFrameImageType = .defaultBlack
        }
        
        frameImageGenerator.changeFrame(to: newFrameImageType)
        let newFrameImage = frameImageGenerator.generate()
        output.send(.frameImage(image: newFrameImage))
    }
    
    private func appendSticker(with sticker: StickerEntity) {
        var currentStickerObjectList = stickerObjectListSubject.value
        currentStickerObjectList.append(sticker)
        stickerObjectListSubject.send(currentStickerObjectList)
    }
    
    private func fetchEmojiList() {
        fetchEmojiListUseCase.execute()
            .sink { [weak self] emojiEntities in
                self?.emojiList = emojiEntities
            }
            .store(in: &cancellables)
    }
    
    private func sendEmoji() {
        output.send(.emojiEntity(entity: emojiList.randomElement()!))
    }
    
    private func sendToRepository(type: EventType, with sticker: StickerEntity) {
        sendStickerToRepositoryUseCase.execute(type: type, sticker: sticker)
    }
    
    func setupFrame() {
        let frameImage = frameImageGenerator.generate()
        output.send(.frameImage(image: frameImage))
    }
}
