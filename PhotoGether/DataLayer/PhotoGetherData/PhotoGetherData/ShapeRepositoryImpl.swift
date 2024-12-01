import Combine
import Foundation
import PhotoGetherDomainInterface
import PhotoGetherNetwork

final public class ShapeRepositoryImpl: ShapeRepository {
    public func fetchEmojiList() -> AnyPublisher<[EmojiEntity], Never> {
        return localDataSource.fetchEmojiData(EmojiEndPoint())
            .catch { [weak self] _ -> AnyPublisher<[EmojiDTO], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                
                return remoteDataSource.fetchEmojiData(EmojiEndPoint())
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .map { $0.map { $0.toEntity() } }
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


fileprivate struct EmojiEndPoint: EndPoint {
    let group: EmojiGroup
    
    var baseURL: URL { URL(string: "https://www.emoji.family")! }
    var path: String { "api/emojis" }
    var method: HTTPMethod { .get }
    var parameters: [String: Any]? { ["group": group] }
    var headers: [String: String]? { nil }
    var body: Encodable? { nil }
    
    init(group: EmojiGroup) {
        self.group = group
    }
}

