import Foundation
import Combine

public enum Request {
    public static func requestJSON<E: EndPoint, T: Decodable>(
        _ endPoint: E,
        decoder: JSONDecoder = .init(),
        queue: DispatchQueue = .main
    ) -> AnyPublisher<T, any Error> {
        decoder.dateDecodingStrategy = .iso8601
        return URLSession.shared.dataTaskPublisher(for: endPoint.request())
            .timeout(.seconds(10), scheduler: RunLoop.main)
            .map { output in
                printNetworkLog(request: endPoint.request(), output: output)
            }
            .tryMap(responseToData)
            .decode(type: T.self, decoder: decoder)
            .mapError(\.asAPIError)
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    public static func requestVoid<E: EndPoint>(_ endPoint: E, queue: DispatchQueue = .main) -> AnyPublisher<Void, any Error> {
        return URLSession.shared.dataTaskPublisher(for: endPoint.request())
            .timeout(.seconds(10), scheduler: RunLoop.main)
            .map { output in
                printNetworkLog(request: endPoint.request(), output: output)
            }
            .tryMap(responseToData)
            .map { _ in () }
            .mapError(\.asAPIError)
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
}

private extension Request {
    static func responseToData(_ output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let httpResponse = output.response as? HTTPURLResponse else {
            throw APIError.custom(message: "응답이 없습니다.", code: 999)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return output.data
        case 400:
            throw APIError.badRequest
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.unknown
        }
    }
    
    static func printNetworkLog(request: URLRequest, output: URLSession.DataTaskPublisher.Output) -> URLSession.DataTaskPublisher.Output {
        // Request 정보 출력
        let method = request.httpMethod ?? "unknown method"
        let url = request.url?.absoluteString ?? "Unknown URL"
        
        print("====================\n\n[\(method)] \(url)\n\n====================\n")
        
        print("====================[ Request Headers ]====================\n")
        
        if let headers = request.allHTTPHeaderFields {
            print("\(headers)")
        } else {
            print("header를 찾을 수 없습니다.")
        }
        
        print("\n====================[ End Request Headers ]====================\n")
        
        // Request Body 출력
        print("\n====================[ Request Body ]====================\n")
        
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("\(bodyString)")
        } else {
            print("Unable to encode utf8")
        }
        
        print("\n====================[ End Request Body ]====================\n")
        
        // Response 정보 출력
        let httpResponse = output.response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1
                
        print("====================\n\n[\(statusCode)]\n[\(url)]\n\n====================\n")
        
        // Response Body 출력
        print("\n====================[ Response Body ]====================\n")
        if let bodyString = String(data: output.data, encoding: .utf8) {
//            print("\(bodyString)")
            print("count:\(bodyString.count)")
        } else {
            print("Unable to encode utf8")
        }
        print("\n====================[ End Body ]====================\n")
        
        return output
    }
}
