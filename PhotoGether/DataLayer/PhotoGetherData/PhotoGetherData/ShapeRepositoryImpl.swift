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
    var baseURL: URL { URL(string: "https://api.api-ninjas.com")! }
    var path: String { "v1/emoji" }
    var method: HTTPMethod { .get }
    /// offset 기준 30개씩 호출
    var parameters: [String: Any]? { ["group": "objects", "offset": 0] }
    var headers: [String: String]? {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "EMOJI_API_KEY") as? String ?? ""
        return ["X-Api-Key": apiKey]
    }
    var body: Encodable? { nil }
}
