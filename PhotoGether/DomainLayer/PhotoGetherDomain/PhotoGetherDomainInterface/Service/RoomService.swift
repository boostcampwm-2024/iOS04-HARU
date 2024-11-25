import Foundation
import Combine

public protocol RoomService {
    var createRoomResponsePublisher: AnyPublisher<CreateRoomEntity, Error> { get }
    
    func createRoom() -> AnyPublisher<CreateRoomEntity, Error>
    func joinRoom()
}
