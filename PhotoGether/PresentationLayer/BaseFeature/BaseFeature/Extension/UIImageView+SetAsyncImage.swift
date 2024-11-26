import UIKit

public extension UIImageView {
    @MainActor
    func setAsyncImage(_ url: URL) async {
        let cachedImage = ImageCache.readCache(with: url)
        if cachedImage == nil { // MARK: 캐시 히트에 실패한 경우
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let image = UIImage(data: data)
                else {
                    debugPrint("이미지 다운로드 실패: \(url)")
                    return
                }
                
                let cachingImage = CacheableImage(imageData: data)
                ImageCache.updateCache(with: url, image: cachingImage)
                
                self.image = image
                
            } catch {
                debugPrint("이미지 다운로드 중 오류 발생: \(error.localizedDescription)")
            }
        } else { // MARK: 캐시 히트
            guard let cachedUIImage = UIImage(data: cachedImage!.imageData) else {
                debugPrint("캐싱이미지 변환에 실패했습니다. \(url)")
                return
            }
            
            self.image = cachedUIImage
        }
    }
}
