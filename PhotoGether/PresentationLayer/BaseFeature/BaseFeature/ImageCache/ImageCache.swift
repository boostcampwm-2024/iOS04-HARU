import UIKit

public enum ImageCache {
    private static let memoryCache: NSCache<NSString, CacheableImage> = {
        let memoryCache = NSCache<NSString, CacheableImage>()
        memoryCache.totalCostLimit = 1024 * 1024 * 50 // MARK: 메모리 캐시 최대 용량 50MB
        return memoryCache
    }()
    
    private static let diskCache: ImageDiskCache = {
        let diskCache = ImageDiskCache()
        return diskCache
    }()
    
    /// 메모리 캐시의 최대 용량을 설정합니다.
    public static func setMaximumMemoryCache(with maximumBytes: Int) {
        self.memoryCache.totalCostLimit = maximumBytes
    }
    
    public static func readCache(with imageURL: URL) -> CacheableImage? {
        let imageURLStr = imageURL.absoluteString as NSString
        
        if let memoryCachedImage = memoryCache.object(forKey: imageURLStr) {
            return memoryCachedImage
        } else {
            guard let diskCachedImage = diskCache.readCache(with: imageURL) else { return nil }
            memoryCache.setObject(diskCachedImage, forKey: imageURLStr)
            return diskCachedImage
        }
    }
    
    public static func updateCache(with imageURL: URL, image: CacheableImage) {
        let key = imageURL.absoluteString as NSString
        memoryCache.setObject(image, forKey: key)
        diskCache.updateCache(with: imageURL, image: image)
    }
    
    public static func removeCache() {
        memoryCache.removeAllObjects()
        diskCache.removeCache()
    }
    
}

public class DiskCache<K, V> where K: NSString, V: Codable {
    let fileManager = FileManager.default
    let cacheDirectoryPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
}

public final class ImageDiskCache: DiskCache<NSString, CacheableImage> {
    public func readCache(with imageURL: URL) -> CacheableImage? {
        guard let path = super.cacheDirectoryPath else { return nil }
        let filePath = path.appendingPathComponent(imageURL.pathComponents.joined(separator: "-"))
        
        if fileManager.fileExists(atPath: filePath.path) {
            guard let imageData = try? Data(contentsOf: filePath) else { return nil }
            return CacheableImage(imageData: imageData)
        }
        return nil
    }
    
    public func updateCache(with imageURL: URL, image: CacheableImage) {
        guard let path = super.cacheDirectoryPath else { return }
        let filePath = path.appendingPathComponent(imageURL.pathComponents.joined(separator: "-"))
        
        fileManager.createFile(atPath: filePath.path, contents: image.imageData)
    }
    
    public func removeCache() {
        guard let path = super.cacheDirectoryPath else { return }
        guard let files = try? fileManager.contentsOfDirectory(atPath: path.path) else { return }
        
        files.forEach {
            let filePath = path.appendingPathComponent($0)
            try? fileManager.removeItem(at: filePath)
        }
    }
}
