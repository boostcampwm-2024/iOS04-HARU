import Foundation

public protocol RoomService {
    func send(request: Encodable)
}
