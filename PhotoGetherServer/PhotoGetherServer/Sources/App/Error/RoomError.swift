import Foundation

enum RoomError: LocalizedError {
    case createFailed
    case joinFailed
    
    var errorDescription: String? {
        switch self {
        case .createFailed:
            return "Failed to create room"
        case .joinFailed:
            return "Failed to join room"
        }
    }
}
