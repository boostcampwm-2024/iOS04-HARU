import UIKit
import Photos

struct PhotoLibraryHelper {
    static func savePhoto(with data: Data) async -> Bool {
        
        guard let photoImage = UIImage(data: data) else { return false }
        
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: photoImage)
            }) { success, error in
                if let error = error {
                    print("Error saving photo: \(error.localizedDescription)")
                } else if success {
                    print("Photo saved successfully!")
                }
                continuation.resume(returning: success)
            }
        }
    }
}
