import Foundation

public protocol RoomService {
    func createRoom() -> Bool
    func joinRoom()
}
