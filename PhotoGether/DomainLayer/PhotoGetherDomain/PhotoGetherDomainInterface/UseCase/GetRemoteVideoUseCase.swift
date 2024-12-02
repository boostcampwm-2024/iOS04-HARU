import Foundation
import UIKit

public protocol GetRemoteVideoUseCase {
    func execute() -> [(UserInfo?, UIView)]
}
