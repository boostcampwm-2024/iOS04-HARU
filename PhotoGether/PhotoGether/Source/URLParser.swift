import Foundation

public enum URLParser {
    public static func parsingRoomID(from url: URL) -> String? {
        guard let queryItems = parsingURLQueryItems(url) else { return nil }
        
        let roomID = queryItems.first(where: { $0.name == "roomID" })?.value
        
        return roomID
    }
    
    private static func parsingURLQueryItems(_ url: URL) -> [URLQueryItem]? {
        guard let urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else { return nil }
        
        return urlComponents.queryItems
    }
}
