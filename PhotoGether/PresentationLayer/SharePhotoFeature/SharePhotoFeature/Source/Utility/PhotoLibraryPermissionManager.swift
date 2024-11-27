import Photos

struct PhotoLibraryPermissionManager {
    static func checkPhotoPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        print(status)
        switch status {
        case .notDetermined:
            return await requestAuthorization()
        case .authorized, .limited:
            return true
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    private static func requestAuthorization() async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                let isAuthorized = (newStatus == .authorized || newStatus == .limited)
                continuation.resume(returning: isAuthorized)
            }
        }
    }
}
