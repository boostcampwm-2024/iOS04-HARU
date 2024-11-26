import Foundation
import Vapor

package extension ByteBuffer {
    func toDTO<T: Decodable>(type: T.Type, decoder: JSONDecoder) -> T? {
        return try? decoder.decode(type, from: self)
    }
}
