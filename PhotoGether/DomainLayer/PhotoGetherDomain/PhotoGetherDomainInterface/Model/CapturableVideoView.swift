import Foundation
import WebRTC

public class CapturableVideoView: RTCMTLVideoView {
    public var capturedImage: UIImage?

    public override func setSize(_ size: CGSize) {
        super.setSize(size)
        // 필요에 따라 구현 가능 (여기서는 생략)
    }

    public override func renderFrame(_ frame: RTCVideoFrame?) {
        guard let frame = frame else { return }
        
        super.renderFrame(frame)
        // RTCVideoFrame을 UIImage로 변환하여 캡처
        capturedImage = convertFrameToImage(frame)
    }

    private func convertFrameToImage(_ frame: RTCVideoFrame) -> UIImage? {
        // frame의 버퍼를 CVPixelBuffer로 가져옴
        guard let pixelBuffer = (frame.buffer as? RTCCVPixelBuffer)?.pixelBuffer else { return nil }
        
        // CVPixelBuffer를 CIImage로 변환
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)
        
        // CIImage를 UIImage로 변환
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
