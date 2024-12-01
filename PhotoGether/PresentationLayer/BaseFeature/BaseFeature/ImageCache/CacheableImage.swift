import Foundation

public final class CacheableImage: Codable {
    let imageData: Data
    
    public init(imageData: Data) {
        self.imageData = imageData
    }
}
