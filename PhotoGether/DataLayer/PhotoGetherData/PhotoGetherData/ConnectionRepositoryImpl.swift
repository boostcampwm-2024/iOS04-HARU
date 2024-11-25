import Foundation
import PhotoGetherDomainInterface

public final class ConnectionRepositoryImpl: ConnectionRepository {
    public var clients: [ConnectionClient]
    
    private let localVideoView = CapturableVideoView()
    
    private let roomService: RoomService
    
    public init(clients: [ConnectionClient], roomService: RoomService) {
        self.clients = clients
        self.roomService = roomService
        bindLocalVideo()
    }
    
    private func bindLocalVideo() {
        self.clients.forEach { $0.bindLocalVideo(localVideoView) }
    }
}
