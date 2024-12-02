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
        guard let capturer = videoCapturer as? RTCCameraVideoCapturer else { return }
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
    func stopCaptureLocalVideo() -> Bool {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else { return false }
        capturer.stopCapture()
        return true
    }
    
    /// 카메라 전후면을 전환하고 다시 비디오 캡쳐를 시작합니다.
    func toggleCameraPosition() async {
        currentCameraPosition = currentCameraPosition == .front ? .back : .front
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
