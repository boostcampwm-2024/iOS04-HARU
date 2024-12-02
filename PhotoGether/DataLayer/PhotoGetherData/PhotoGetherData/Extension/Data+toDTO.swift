import Foundation
import PhotoGetherNetwork
import CoreModule

public extension Data {
    func toDTO<T: Decodable>(type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> T? {
        do {
            return try decoder.decode(type, from: self)
        } catch let decodingError as DecodingError {
            PTGLogger.default.log("Decoding Error: \(decodingError.fullDescription)", level: .debug)
        } catch {
            PTGLogger.default.log("Unknown Decoding error: \(error.localizedDescription)", level: .debug)
        }
        return nil
    }
}
