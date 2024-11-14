import Combine
import Foundation
import PhotoGetherDomainInterface

public final class SharePhotoViewModel {
    public private(set) var photoData: Data
    
    public init(component: SharePhotoComponent) {
        self.photoData = component.photoData
    }
}
