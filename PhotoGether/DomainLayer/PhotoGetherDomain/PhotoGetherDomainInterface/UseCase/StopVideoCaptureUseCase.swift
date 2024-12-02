import Foundation

public protocol StopVideoCaptureUseCase {
    @discardableResult
    func execute() -> Bool
}
