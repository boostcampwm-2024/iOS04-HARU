import Combine
import Foundation
import PhotoGetherDomainInterface

public final class ShapeRepositoryMock: ShapeRepository {
    private let imageNameList: [String]
    
    public init(imageNameList: [String]) {
        self.imageNameList = imageNameList
    }
    
    public func fetchStickerList() -> AnyPublisher<[Data], Never> {
        let imageDataList = imageNameList.map { imageData(named: $0) }
        return Just(imageDataList.compactMap { $0 })
            .eraseToAnyPublisher()
    }
    
    private func imageData(named: String) -> Data? {
        let bundle = Bundle(for: Self.self)
        let imageData = bundle.url(forResource: named, withExtension: "svg")?
            .dataRepresentation
        return imageData
    }
}
