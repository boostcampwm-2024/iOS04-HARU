import UIKit

public protocol ConnectionRepository {
    var clients: [ConnectionClient] { get }
    var roomService: RoomService { get }
    var localVideoView: UIView { get }
    var CapturedLocalVideo: UIImage? { get }
}
