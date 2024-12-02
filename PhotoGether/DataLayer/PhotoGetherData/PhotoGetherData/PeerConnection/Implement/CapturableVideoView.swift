import Foundation
import CoreGraphics
import WebRTC

public class CapturableVideoView: RTCMTLVideoView {
    private var capturedCGImage: CGImage?
    
    public var capturedImage: UIImage? {
        guard let capturedCGImage,
              let flipedImage = flipCgImageHorizontally(cgImage: capturedCGImage)
        else { return nil }
        
        return UIImage(cgImage: flipedImage)
    }
    
    public override func setSize(_ size: CGSize) {
        super.setSize(size)
    }
    
    public override func renderFrame(_ frame: RTCVideoFrame?) {
        guard let frame = frame else { return }
        
        super.renderFrame(frame)
        capturedCGImage = convertFrameToImage(frame)
    }
    
    private func convertFrameToImage(_ frame: RTCVideoFrame) -> CGImage? {
        // frame의 버퍼를 CVPixelBuffer로 가져옴
        guard let pixelBuffer = (frame.buffer as? RTCCVPixelBuffer)?.pixelBuffer else { return nil }
        
        // CVPixelBuffer를 CIImage로 변환
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)
        
        // CIImage를 UIImage로 변환
        let context = CIContext(options: nil)
        
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return cgImage
        }
        return nil
    }
    
    private func flipCgImageHorizontally(cgImage: CGImage) -> CGImage? {
        let width = cgImage.width
        let height = cgImage.height
        
        // 비트맵 컨텍스트 생성
        guard let colorSpace = cgImage.colorSpace,
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: cgImage.bitsPerComponent,
                bytesPerRow: cgImage.bytesPerRow,
                space: colorSpace,
                bitmapInfo: cgImage.bitmapInfo.rawValue
              ) else {
            return nil
        }
        
        context.translateBy(x: CGFloat(width), y: 0)
        context.scaleBy(x: -1, y: 1)
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        return context.makeImage()
    }
}
