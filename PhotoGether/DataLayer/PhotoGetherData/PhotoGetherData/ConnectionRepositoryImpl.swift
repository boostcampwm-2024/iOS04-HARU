import UIKit
import PhotoGetherDomainInterface


public final class ConnectionRepositoryImpl: ConnectionRepository {
    public var clients: [ConnectionClient]
    
    private let _localVideoView = CapturableVideoView()
    
    public var localVideoView: UIView { _localVideoView }
    public var capturedLocalVideo: UIImage? { _localVideoView.capturedImage }
    
    public let roomService: RoomService
    
    public init(clients: [ConnectionClient], roomService: RoomService) {
        self.clients = clients
        self.roomService = roomService
        bindLocalVideo()
    }
    
    private func bindLocalVideo() {
        self.clients.forEach { $0.bindLocalVideo(_localVideoView) }
    }
}
