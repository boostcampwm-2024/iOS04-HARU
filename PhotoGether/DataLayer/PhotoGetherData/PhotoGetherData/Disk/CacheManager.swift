import Combine
import OSLog
import UIKit

final class CacheManager {
    private let fileManager: FileManager
    private let cacheDirectory: URL
    
    init() {
        self.fileManager = .default
        self.cacheDirectory = fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
    }
    
    /// 데이터 캐싱
    ///
    /// key(URL String)와 data를 Disk cache에 저장
    /// key의 hash값을 path로 설정하여 중복 방지
    func save(key: String, data: Data) {
        let fileURL = cacheDirectory.appendingPathComponent(key.hashValue.description)
        
        do { try data.write(to: fileURL) }
        catch { os_log("ERROR: Failed to save data to disk\n\(error.localizedDescription)") }
    }
    
    /// 캐시 데이터 불러오기
    ///
    /// key(URL String)을 기반으로 캐시 메모리를 탐색하여 Data?를 반환
    func load(key: String) -> Data? {
        let fileURL = cacheDirectory.appendingPathComponent(key.hashValue.description)
        
        return try? Data(contentsOf: fileURL)
    }
    
    /// 캐시 데이터 불러오기
    ///
    /// key(URL String)을 기반으로 캐시 메모리를 탐색하여 AnyPublisher<Data?, Error>를 반환
    func loadPublisher(key: String) -> AnyPublisher<Data?, Error> {
        let fileURL = cacheDirectory.appendingPathComponent(key.hashValue.description)
        
        return Future<Data?, Error> { promise in
            do {
                let data = try Data(contentsOf: fileURL)
                print("DEBUG: Loaded data from disk")
                promise(.success(data))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension CacheManager {
    static let emoji = "emoji"
}
