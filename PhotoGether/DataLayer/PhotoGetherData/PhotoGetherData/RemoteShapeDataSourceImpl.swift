import Combine
import Foundation
import PhotoGetherNetwork

public final class RemoteShapeDataSourceImpl: ShapeDataSource {
    // TODO: 페이징 적용 필요
    public func fetchEmojiData() -> AnyPublisher<[EmojiDTO], Error> {
        return Request.requestJSON(EmojiEndPoint())
    }
    
    public init() { }
}

private struct EmojiEndPoint: EndPoint {
    var baseURL: URL { URL(string: "https://api.api-ninjas.com")! }
    var path: String { "v1/emoji" }
    var method: HTTPMethod { .get }
    // 시작 인덱스, 1회 호출당 30개씩 호출
    var parameters: [String: Any]? { ["group": "objects", "offset": 0] }
    var headers: [String: String]? {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "EMOJI_API_KEY") as? String ?? ""
        return ["X-Api-Key": apiKey]
    }
    var body: Encodable? { nil }
}
