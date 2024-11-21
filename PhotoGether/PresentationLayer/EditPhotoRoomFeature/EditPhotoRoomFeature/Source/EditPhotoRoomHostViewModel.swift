import Foundation
import Combine
import PhotoGetherDomainInterface

public final class EditPhotoRoomHostViewModel {
    enum Input {
        case stickerButtonDidTap
    }

    enum Output {
        case emojiEntity(entity: EmojiEntity)
    }
    
    private let fetchEmojiListUseCase: FetchEmojiListUseCase
    private var emojiList: [EmojiEntity] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init(
        fetchEmojiListUseCase: FetchEmojiListUseCase
    ) {
        self.fetchEmojiListUseCase = fetchEmojiListUseCase
        bind()
    }
    
    private func bind() {
        fetchEmojiList()  // 처음 한번 부르고 부터는 재호출을 안하도록
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] in
            switch $0 {
            case .stickerButtonDidTap:
                self?.addStickerToCanvas()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func fetchEmojiList() {
        fetchEmojiListUseCase.execute()
            .sink { [weak self] emojiEntities in
                self?.emojiList = emojiEntities
            }
            .store(in: &cancellables)
    }
    
    private func addStickerToCanvas() {
        output.send(.emojiEntity(entity: emojiList.randomElement()!))
    }
}
