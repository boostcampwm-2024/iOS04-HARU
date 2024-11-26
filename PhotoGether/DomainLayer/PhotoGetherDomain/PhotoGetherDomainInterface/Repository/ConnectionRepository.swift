import UIKit
import Combine

public protocol ConnectionRepository {
    var clients: [ConnectionClient] { get }
    var localVideoView: UIView { get }
    var capturedLocalVideo: UIImage? { get }
    
    func createRoom() -> AnyPublisher<RoomOwnerEntity, Error>
    func joinRoom(to roomID: String, hostID: String) -> AnyPublisher<Bool, Error>
}
