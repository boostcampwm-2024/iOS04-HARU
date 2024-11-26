import Foundation
import Combine

public protocol RoomService {
    var createRoomResponsePublisher: AnyPublisher<RoomOwnerEntity, Error> { get }
    
    func createRoom() -> AnyPublisher<RoomOwnerEntity, Error>
    func joinRoom(to roomID: String) -> AnyPublisher<JoinRoomEntity, Error>
}
