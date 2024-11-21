import Foundation
import Combine
import PhotoGetherDomainInterface

public final class EditPhotoRoomGuestViewModel {
    enum Input {
        case stickerButtonDidTap
        case stickerObjectData(StickerObject)
    }
    
    enum Output {
        case stickerImageData(data: Data)
        case stickerObjectList([StickerObject])
    }
    
    private let fetchStickerListUseCase: FetchStickerListUseCase
    private let connectionClient: ConnectionClient
    
    private var stickerImageList: [Data] = []
    private var stickerObjectListSubject = CurrentValueSubject<[StickerObject], Never>([])
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init(
        fetchStickerListUseCase: FetchStickerListUseCase,
        connectionClient: ConnectionClient
    ) {
        self.fetchStickerListUseCase = fetchStickerListUseCase
        self.connectionClient = connectionClient
        bind()
    }
    
    private func bind() {
        fetchStickerList()
        
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
                self?.sendStickerImage()
            case .stickerObjectData(let sticker):
                self?.appendSticker(with: sticker)
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func appendSticker(with sticker: StickerObject) {
        var currentStickerObjectList = stickerObjectListSubject.value
        currentStickerObjectList.append(sticker)
        stickerObjectListSubject.send(currentStickerObjectList)
    }
    
    private func fetchStickerList() {
        fetchStickerListUseCase.execute()
            .sink { [weak self] datas in
                self?.stickerImageList = datas
            }
            .store(in: &cancellables)
    }
    
    private func sendStickerImage() {
        output.send(.stickerImageData(data: stickerImageList.randomElement()!))
    }
}

struct StickerObject {
    let id: UUID
    let image: Data
    let rect: CGRect
}
