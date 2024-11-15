import Foundation

public struct SharePhotoComponent {
    public let photoData: Data
    
    public init(imageData: Data) {
        self.photoData = imageData
    }
}
