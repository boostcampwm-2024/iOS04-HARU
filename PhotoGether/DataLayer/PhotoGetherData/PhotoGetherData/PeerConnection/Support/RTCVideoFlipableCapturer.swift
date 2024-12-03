import WebRTC

class RTCVideoFlipableCapturer: RTCVideoCapturer, RTCVideoCapturerDelegate {
    private var cameraCapturer: RTCCameraVideoCapturer? // 실제 카메라 캡처
    private weak var videoSource: RTCVideoSource?
    private(set) var isFlipped: Bool
    
    init(videoSource: RTCVideoSource, isFlipped: Bool = false) {
        self.videoSource = videoSource
        self.isFlipped = isFlipped
        super.init(delegate: videoSource)
        self.cameraCapturer =  RTCCameraVideoCapturer(delegate: self) // 델리게이트 연결
    }
    
    /// 내부적으로 AVCaptureSession을 사용해 카메라 화면을 frame단위로 캡쳐 및 변환하여 capturer로 전달합니다.
    /// - Parameters:
    ///   - device: 전/후면 모드를 포함하는 카메라 디바이스
    ///   - format: 해상도
    ///   - fps: frame rate
    /// - Returns: 정렬된 fps 배열
    func startCapture(
        with device: AVCaptureDevice,
        format: AVCaptureDevice.Format,
        fps: Int
    ) async throws {
        print(#function, "startCapture")
        try await cameraCapturer?.startCapture(with: device, format: format, fps: fps)
    }
    
    func stopCapture() async {
        await cameraCapturer?.stopCapture()
    }
    
    /// 내부에서 알아서 호출되는 메소드입니다. isFlipped 상태에 따라 좌우반전해 렌더링합니다.
    func capturer(_ capturer: RTCVideoCapturer, didCapture frame: RTCVideoFrame) {
        renderFlipableFrame(frame)
    }
    
    func toggleFlip() {
        isFlipped.toggle()
    }
    
    private func renderFlipableFrame(_ frame: RTCVideoFrame) {
        if isFlipped, let rtcPixelBuffer = frame.buffer as? RTCCVPixelBuffer {
            let flippedBuffer = flipBufferHorizontally(from: rtcPixelBuffer.pixelBuffer)
            let flippedRTCBuffer = RTCCVPixelBuffer(pixelBuffer: flippedBuffer)
            let flippedFrame = RTCVideoFrame(
                buffer: flippedRTCBuffer,
                rotation: frame.rotation, // 비디오 프레임의 회전 정보 (_0, _90, _180, _270 존재)
                timeStampNs: frame.timeStampNs // 비디오 프레임의 타임스탬프(나노 초)
            )
            // 수정된 프레임을 videoSource로 전달
            self.videoSource?.capturer(self, didCapture: flippedFrame)
            self.localVideoTrack?.source.capturer(self, didCapture: flippedFrame)
        } else {
            self.videoSource?.capturer(self, didCapture: frame)
        }
    }
    
    private func flipBufferHorizontally(from buffer: CVPixelBuffer) -> CVPixelBuffer {
        // Core Image를 사용해 좌우 반전
        let flippedCIImage = CIImage(cvPixelBuffer: buffer)
            .oriented(.leftMirrored)
            .oriented(.upMirrored)
            .oriented(.left)

        let ciContext = CIContext()
        
        var flippedBuffer: CVPixelBuffer? // 새로 생성될 픽셀 버퍼
        CVPixelBufferCreate(
            nil, // CFAllocator 메모리 할당 관리자로 nil로 하면 기본 설정
            CVPixelBufferGetWidth(buffer),
            CVPixelBufferGetHeight(buffer),
            CVPixelBufferGetPixelFormatType(buffer),
            nil, // 픽셀 버퍼 옵셔널 속성
            &flippedBuffer // 생성된 버퍼 반환
        )
        
        guard let flippedBuffer else { return buffer }
        
        CVPixelBufferLockBaseAddress(flippedBuffer, [])
        ciContext.render(flippedCIImage, to: flippedBuffer)
        CVPixelBufferUnlockBaseAddress(flippedBuffer, [])
        
        return flippedBuffer
    }
}
