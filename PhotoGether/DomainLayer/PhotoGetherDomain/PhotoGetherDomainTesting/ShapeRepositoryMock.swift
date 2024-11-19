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
        let bundle = Bundle(for: Self.self) // 해당 클래스가 존재하는 Bundle을 의미
        guard let imageURL = bundle.url(forResource: named, withExtension: "png"),
              let imageData = try? Data(contentsOf: imageURL)
        else { debugPrint("bundle Image to Data error"); return nil }
        
        return imageData
    }
}
