import WebRTC
import CoreModule

class VideoCaptureManager {
    private(set) weak var videoCapturer: RTCVideoCapturer?
    private(set) weak var videoSource: RTCVideoSource?

    private(set) var currentCameraPosition: AVCaptureDevice.Position = .front
    
    init() { }
    
    func setVideoCapturer(_ videoCapturer: RTCVideoCapturer?) {
        self.videoCapturer = videoCapturer
    }
    
    func setVideoSource(_ videoSource: RTCVideoSource?) {
        self.videoSource = videoSource
    }
    
    /// 비디오 캡쳐를 시작합니다.
    func startCaptureLocalVideo() async {
        guard let capturer = videoCapturer as? RTCVideoFlipableCapturer else { return }
        guard let cameraDevice = cameraDevice(for: currentCameraPosition) else { return }
        guard let selection = selectFormatAndFrameRate(for: cameraDevice) else { return }

        do {
            try await capturer.startCapture(
                with: cameraDevice,
                format: selection.format,
                fps: Int(selection.frameRate)
            )
        } catch {
            PTGLogger.default.log(error.localizedDescription)
        }
    }
    
    /// 비디오 캡쳐를 중지합니다.
    func stopCaptureLocalVideo() async -> Bool {
        guard let capturer = self.videoCapturer as? RTCVideoFlipableCapturer else { return false }
        await capturer.stopCapture()
        return true
    }
    
    /// 카메라 전후면을 전환하고 다시 비디오 캡쳐를 시작합니다.
    func toggleCameraPosition() async {
        if let capturer = videoCapturer as? RTCVideoFlipableCapturer {
            capturer.toggleFlip()
        }
        currentCameraPosition = currentCameraPosition == .front ? .back : .front
//        await stopCaptureLocalVideo()
        await startCaptureLocalVideo()
    }
    
    /// 주어진 카메라 포지션에 맞는 디바이스를 반환합니다.
    private func cameraDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return RTCCameraVideoCapturer.captureDevices().first { $0.position == position }
    }
    
    /// 파라미터로 받은 카메라의 해상도를 정렬하여 리턴합니다.
    /// - Parameters:
    ///   - device: 정렬할 카메라 디바이스
    ///   - order: 정렬 방향 (기본값은 오름차순)
    /// - Returns: 정렬된 해상도 포맷 배열
    private func sortedFormats(
        for device: AVCaptureDevice,
        order: (Int32, Int32) -> Bool = (<)
    ) -> [AVCaptureDevice.Format] {
        return RTCCameraVideoCapturer.supportedFormats(for: device)
            .sorted { frame1, frame2 -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(frame1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(frame2.formatDescription).width
                return order(width1, width2)
            }
    }
    
    /// 파라미터로 받은 해상도의 fps를 정렬하여 리턴합니다.
    /// - Parameters:
    ///   - format: fps를 찾을 해상도
    ///   - order: 정렬 방향 (기본값은 오름차순)
    /// - Returns: 정렬된 fps 배열
    private func sortedFrameRates(
        for format: AVCaptureDevice.Format,
        order: (Float64, Float64) -> Bool = (<)
    ) -> [AVFrameRateRange] {
        return format.videoSupportedFrameRateRanges
            .sorted { order($0.maxFrameRate, $1.maxFrameRate) }
    }

    /// 가장 낮은 해상도와 가장 높은 fps를 반환합니다.
    private func selectFormatAndFrameRate(
        for device: AVCaptureDevice
    ) -> (format: AVCaptureDevice.Format, frameRate: Float64)? {
        guard let lowestFormat = sortedFormats(for: device).first else { return nil }
        guard let highestFrameRate = sortedFrameRates(for: lowestFormat).last?.maxFrameRate else { return nil }
        return (lowestFormat, highestFrameRate)
    }
}

class RTCVideoFlipableCapturer: RTCVideoCapturer, RTCVideoCapturerDelegate {
    private weak var videoSource: RTCVideoSource?
    private var cameraCapturer: RTCCameraVideoCapturer? // 실제 카메라 캡처
    private(set) var isFlipped: Bool
    
    init(videoSource: RTCVideoSource, isFlipped: Bool = false) {
        self.videoSource = videoSource
        self.isFlipped = isFlipped
        super.init(delegate: videoSource)
        self.cameraCapturer =  RTCCameraVideoCapturer(delegate: self) // 델리게이트 연결
    }
    
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
    
    /// 내부에서 알아서 호출되는 메소드입니다.
    func capturer(_ capturer: RTCVideoCapturer, didCapture frame: RTCVideoFrame) {
        //print(#function, "capturer")
        //renderFlipableFrame(frame)
        self.delegate?.capturer(self, didCapture: frame)
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
            print(#function, "flip w:\(flippedFrame.width), h:\(flippedFrame.height))")
            self.videoSource?.capturer(self, didCapture: flippedFrame)
        } else {
            print(#function, "flip w:\(frame.width), h:\(frame.height))")
            self.videoSource?.capturer(self, didCapture: frame)
        }
    }
    
    private func flipBufferHorizontally(from buffer: CVPixelBuffer) -> CVPixelBuffer {
        // Core Image를 사용해 좌우 반전
        let flipedCIImage = CIImage(cvPixelBuffer: buffer)
            .transformed(by: CGAffineTransform(scaleX: -1.0, y: 1.0))
        // 위치 조정
        let identityImage = flipedCIImage.transformed(
            by: CGAffineTransform(translationX: flipedCIImage.extent.width, y: 1.0)
        )
        
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
        ciContext.render(identityImage, to: flippedBuffer)
        CVPixelBufferUnlockBaseAddress(flippedBuffer, [])
        
        
        return flippedBuffer
    }
}
