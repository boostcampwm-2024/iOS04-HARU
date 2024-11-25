import Foundation
import Vapor

package extension ByteBuffer {
    func toDTO<T: Decodable>(type: T.Type) -> T? {
        return try? JSONDecoder().decode(type, from: self)
    }
}
