import Foundation
import Combine
import PhotoGetherDomainInterface

public final class EditPhotoRoomHostViewModel {
    enum Input {
        case stickerButtonDidTap
    }

    enum Output {
        case rectangle(rect: Rectangle)
    }
    
    private let fetchStickerListUseCase: FetchStickerListUseCase
    private let stickerList = PassthroughSubject<[Data], Never>()
    
    private var cancellables = Set<AnyCancellable>()
    private var output = PassthroughSubject<Output, Never>()
    
    public init(
        fetchStickerListUseCase: FetchStickerListUseCase
    ) {
        self.fetchStickerListUseCase = fetchStickerListUseCase
        bind()
    }
    
    private func bind() {
        fetchStickerList()  // 처음 한번 부르고 부터는 재호출을 안하도록
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] in
            switch $0 {
            case .stickerButtonDidTap:
                self?.generateRectangle()
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    private func fetchStickerList() {
        fetchStickerListUseCase.execute()
            .sink { [weak self] datas in
                self?.stickerList.send(datas)
            }
            .store(in: &cancellables)
    }
    
    private func generateRectangle() {
        let randomX = Int.random(in: 10..<100)
        let randomY = Int.random(in: 10..<100)
        let width = Int.random(in: 10..<100)
        let height = Int.random(in: 10..<100)
        
        let rectangle = Rectangle(
            position: CGPoint(x: randomX, y: randomY),
            size: CGSize(width: width, height: height)
        )

        output.send(.rectangle(rect: rectangle))
    }
}
