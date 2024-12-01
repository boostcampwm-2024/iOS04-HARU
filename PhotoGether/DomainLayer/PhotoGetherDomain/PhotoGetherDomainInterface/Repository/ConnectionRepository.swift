import UIKit
import Combine

public protocol ConnectionRepository {
    var didEnterNewUserPublisher: AnyPublisher<(UserInfo, UIView), Never> { get }

    var localUserInfo: UserInfo? { get }

    var clients: [ConnectionClient] { get }
    var localVideoView: UIView { get }
    var capturedLocalVideo: UIImage? { get }
    
    func createRoom() -> AnyPublisher<RoomOwnerEntity, Error>
    func joinRoom(to roomID: String, hostID: String) -> AnyPublisher<Bool, Error>
    func sendOffer() async throws
}
