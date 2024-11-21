import Foundation

public enum HTTPMethod: String {
    case get = "GET"
}

public protocol EndPoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var body: Encodable? { get }
}

extension EndPoint {
    public func request() -> URLRequest {
        var url = baseURL.appendingPathComponent(path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        urlComponents.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers?.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
                
        if let body, let jsonData = try? JSONEncoder().encode(body) {
            request.httpBody = jsonData
        }
        
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return request
    }
}
