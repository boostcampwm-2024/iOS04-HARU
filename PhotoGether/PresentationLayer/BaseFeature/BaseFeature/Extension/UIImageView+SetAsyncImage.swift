import UIKit

public extension UIImageView {
    @MainActor
    func setAsyncImage(_ url: URL) async {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let image = UIImage(data: data)
            else {
                debugPrint("이미지 다운로드 실패: \(url)")
                return
            }
            self.image = image
            
        } catch {
            debugPrint("이미지 다운로드 중 오류 발생: \(error.localizedDescription)")
        }
    }
}
