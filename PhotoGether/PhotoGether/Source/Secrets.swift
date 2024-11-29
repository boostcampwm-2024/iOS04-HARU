import Foundation
// swiftlint:disable identifier_name
enum Secrets {
    static var BASE_URL: URL? {
        let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        return URL(string: urlString)
    }
    
    static var STUN_SERVERS: [String]? {
        guard let serversString = Bundle.main.infoDictionary?["STUN_SERVERS"] as? String else {
            return nil
        }
        return serversString.components(separatedBy: ",")
    }
}
