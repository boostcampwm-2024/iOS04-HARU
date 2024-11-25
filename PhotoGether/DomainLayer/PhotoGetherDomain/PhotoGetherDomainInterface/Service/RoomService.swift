import Foundation
import Combine

public protocol RoomService {
    var createRoomResponsePublisher: AnyPublisher<RoomOwnerEntity, Error> { get }
    
    func createRoom() -> AnyPublisher<RoomOwnerEntity, Error>
    func joinRoom()
}
