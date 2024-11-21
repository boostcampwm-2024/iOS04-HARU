import Combine
import Foundation
import PhotoGetherDomainInterface
import UIKit

public final class EditPhotoRoomHostViewModel {
    enum Input {
        case stickerButtonDidTap
        case frameButtonDidTap
        case stickerObjectData(StickerEntity)
    }
    
    enum Output {
        case emojiEntity(entity: EmojiEntity)
        case stickerObjectList([StickerEntity])
        case frameImage(image: UIImage)
    }
    
    private let fetchEmojiListUseCase: FetchEmojiListUseCase
    private let frameImageGenerator: FrameImageGenerator
    
    private var emojiList: [EmojiEntity] = []
    private var stickerObjectListSubject = CurrentValueSubject<[StickerEntity], Never>([])
    private var sendStickerToRepositoryUseCase: SendStickerToRepositoryUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init(
        fetchEmojiListUseCase: FetchEmojiListUseCase,
        frameImageGenerator: FrameImageGenerator,
        sendStickerToRepositoryUseCase: SendStickerToRepositoryUseCase
    ) {
        self.fetchEmojiListUseCase = fetchEmojiListUseCase
        self.frameImageGenerator = frameImageGenerator
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
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .stickerButtonDidTap:
                self?.sendEmoji()
            case .stickerObjectData(let sticker):
                self?.appendSticker(with: sticker)
                self?.sendToRepository(with: sticker)
            case .frameButtonDidTap:
                self?.toggleFrameImage()
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
    
    private func sendToRepository(with sticker: StickerEntity) {
        sendStickerToRepositoryUseCase.execute(type: .create, sticker: sticker)
    }
    
    func setupFrame() {
        let frameImage = frameImageGenerator.generate()
        output.send(.frameImage(image: frameImage))
    }
}
