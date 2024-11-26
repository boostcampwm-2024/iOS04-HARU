import Foundation
import PhotoGetherDomainInterface

public protocol RoomServiceDelegate: AnyObject {
    func roomService(_ roomService: RoomService, didReceiveResponseCreateRoom response: String)
    func roomService(_ roomService: RoomService, didReceiveResponseJoinRoom response: String)
}
