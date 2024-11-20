import Combine
import Foundation
import PhotoGetherDomainInterface

public final class ShapeRepositoryMock: ShapeRepository {
    private let imageNameList: [String]
    
    public init(imageNameList: [String]) {
        self.imageNameList = imageNameList
    }
    
    public func fetchStickerList() -> AnyPublisher<[StickerEntity], Never> {
        let stickerEntities: [StickerEntity] = imageNameList.map {
            .init(
                image: imageData(named: $0),    // 이미지 주소(or 경로)
                name: $0
            )
        }
        
        return Just(stickerEntities).eraseToAnyPublisher()
    }
    
    private func imageData(named: String) -> String {
        let bundle = Bundle(for: Self.self) // 해당 클래스가 존재하는 Bundle을 의미
        guard let path = bundle.url(forResource: named, withExtension: "png")?.absoluteString
        else { return "" }
        
        return path
    }
}
