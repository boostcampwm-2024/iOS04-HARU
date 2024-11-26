import Foundation
import PhotoGetherDomainInterface

public enum DeepLinkParser {
    public static func parseRoomInfo(from url: URL) -> RoomOwnerEntity? {
        guard let queryItems = parsingURLQueryItems(url) else { return nil }
        
        guard let roomID = queryItems.first(where: { $0.name == "roomID" })?.value,
              let hostID = queryItems.first(where: { $0.name == "userID" })?.value else {
            return nil
        }
        
        return RoomOwnerEntity(roomID: roomID, hostID: hostID)
    }
    
    private static func parsingURLQueryItems(_ url: URL) -> [URLQueryItem]? {
        guard let urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        ) else { return nil }
        
        return urlComponents.queryItems
    }
}
