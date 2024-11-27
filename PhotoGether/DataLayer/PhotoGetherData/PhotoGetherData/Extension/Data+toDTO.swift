import Foundation
import PhotoGetherNetwork

public extension Data {
    func toDTO<T: Decodable>(type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> T? {
        do {
            return try decoder.decode(type, from: self)
        } catch let decodingError as DecodingError {
            PTGDataLogger.log("Decoding Error: \(decodingError.fullDescription)")
        } catch {
            PTGDataLogger.log("Unknown Decoding error: \(error.localizedDescription)")
        }
        return nil
    }
}
