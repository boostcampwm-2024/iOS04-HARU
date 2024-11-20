import Foundation
import WebRTC
import PhotoGetherNetwork

public protocol RoomService {
    func send(request: any WebSocketRequestable)
}
