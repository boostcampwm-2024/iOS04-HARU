import Combine
import CryptoKit
import OSLog
import UIKit

final class CacheManager {
private let fileManager: FileManager
    private let cacheDirectory: URL
    
    init(path: String) {
        self.fileManager = .default
        self.cacheDirectory = fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(path)
        
        /// 입력받은 Path로 만들어진 Cache 디렉토리를 확인 및 생성
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(
                    at: cacheDirectory,
                    withIntermediateDirectories: true
                )
            }
            catch { os_log("ERROR: Failed to create \(path) directory - \(error)") }
        }
    }
    
    /// 데이터 캐싱
    ///
    /// key(URL String)와 data를 Disk cache에 저장
    /// key의 hash값을 path로 설정하여 중복 방지
    func save(url: URL, data: Data) {
        let key = hashKey(from: url)
        let fileURL = cacheDirectory.appendingPathComponent(key)

        /// 파일로 데이터를 저장
        do {
            try data.write(to: fileURL)
            os_log("DEBUG: Success to save data to disk")
        }
        catch { os_log("ERROR: Failed to save data to disk - \(error)") }
    }
    
    /// 캐시 데이터 불러오기
    ///
    /// key(URL String)을 기반으로 캐시 메모리를 탐색하여 AnyPublisher<Data?, Error>를 반환
    func loadPublisher(url: URL) -> AnyPublisher<Data?, Error> {
        let key = hashKey(from: url)
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        return Future<Data?, Error> { promise in
            do {
                let data = try Data(contentsOf: fileURL)
                os_log("DEBUG: Success to load data from disk")
                promise(.success(data))
            } catch {
                os_log("ERROR: Failed to load data from - \(error)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func hashKey(from url: URL) -> String {
        let inputData = Data(url.absoluteString.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

extension CacheManager {
    static let emojiPath = "emoji"
}
