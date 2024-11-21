import Combine
import Foundation
import PhotoGetherDomainInterface

final public class ShapeRepositoryImpl: ShapeRepository {
    // TODO: local 먼저 확인 -> remote 데이터 확인하도록 수정
    // MARK: JSON 데이터 내부의 URL을 어느 시점에 다운로드 할것인가...?
    public func fetchEmojiList() -> AnyPublisher<[EmojiEntity], Never> {
        return remoteDataSource.fetchEmojiData()
            .map { $0.map { $0.toEntity() } }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    private let localDataSource: ShapeDataSource
    private let remoteDataSource: ShapeDataSource
    
    public init(
        localDataSource: ShapeDataSource,
        remoteDataSource: ShapeDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
}
