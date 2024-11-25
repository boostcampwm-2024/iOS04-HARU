import Foundation

public protocol CreateRoomUseCase {
    @discardableResult
    func execute() -> Bool
}
