import Foundation

public protocol CreateRoomUseCase {
    func execute() -> Result<(roomID: String, userID: String), Error>
}
