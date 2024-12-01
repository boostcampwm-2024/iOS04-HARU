import Foundation
import UIKit

public protocol GetLocalVideoUseCase {
    func execute() -> (UserInfo?, UIView)
}
