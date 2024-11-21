import Foundation
import Combine
import PhotoGetherDomainInterface

public final class EditPhotoRoomGuestViewModel {
    enum Input {
        case stickerButtonDidTap
        case stickerObjectData(StickerEntity)
    }
    
    enum Output {
        case emojiEntity(entity: EmojiEntity)
        case stickerObjectList([StickerEntity])
    }
    
    private let fetchEmojiListUseCase: FetchEmojiListUseCase
    private let connectionClient: ConnectionClient
    
    private var emojiList: [EmojiEntity] = []
    private var stickerObjectListSubject = CurrentValueSubject<[StickerEntity], Never>([])
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init(
        fetchEmojiListUseCase: FetchEmojiListUseCase,
        connectionClient: ConnectionClient
    ) {
        self.fetchEmojiListUseCase = fetchEmojiListUseCase
        self.connectionClient = connectionClient
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
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
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
}
