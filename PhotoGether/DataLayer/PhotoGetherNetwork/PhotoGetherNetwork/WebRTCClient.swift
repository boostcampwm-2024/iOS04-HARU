import Foundation
import WebRTC

public final class WebRTCClient: NSObject {
    private static let peerConnectionFactory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(
            encoderFactory: videoEncoderFactory,
            decoderFactory: videoDecoderFactory
        )
    }()
    
    weak var delegate: WebRTCClientDelegate?
    let peerConnection: RTCPeerConnection
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let mediaConstraints = [
        kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
        kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue
    ]
    private var videoCapturer: RTCVideoCapturer?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    
    required init(iceServers: [String]) {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: iceServers)]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: [
                "DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue
            ]
        )
        
        guard let peerConnection = WebRTCClient.peerConnectionFactory.peerConnection(
            with: config,
            constraints: constraints,
            delegate: nil
        ) else {
            // TODO: handle Error
            fatalError("Could not create new RTCPeerConnection")
        }
        
        self.peerConnection = peerConnection
        
        super.init()
        
        self.createMediaSenders()
        self.configureAudioSession()
        self.peerConnection.delegate = self
    }
}

// MARK: SDP
extension WebRTCClient {
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: self.mediaConstraints,
            optionalConstraints: nil
        )
        
        // 1. constraints를 통해 내 sdp를 만든다.
        self.peerConnection.offer(for: constraints) { sdp, _ in
            guard let sdp else { return }
            
            // 2. sdp를 peerConnection에 저장한다음 소켓을 통해 시그널링 서버를 거쳐 상대에게 전송한다.
            self.peerConnection.setLocalDescription(sdp) { _ in
                completion(sdp)
            }
        }
    }
    
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: self.mediaConstraints,
            optionalConstraints: nil
        )
        
        // 1. constraints를 통해 내 sdp를 만든다.
        self.peerConnection.answer(for: constraints) { sdp, _ in
            guard let sdp else { return }
            
            // 2. sdp를 peerConnection에 저장한다음 소켓을 통해 시그널링 서버를 거쳐 상대에게 전송한다.
            self.peerConnection.setLocalDescription(sdp) { _ in
                completion(sdp)
            }
        }
    }
    
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> Void) {
        self.peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(localSdp: RTCSessionDescription, completion: @escaping (Error?) -> Void) {
        self.peerConnection.setLocalDescription(localSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> Void) {
        self.peerConnection.add(remoteCandidate, completionHandler: completion)
    }
}

// MARK: Video/Audio/Data
extension WebRTCClient {
    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else { return }
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: {
            $0.position == .front
        }) else { return }
              
        // 가장 높은 해상도 선택
        guard let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera)
            .sorted { frame1, frame2 -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(frame1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(frame2.formatDescription).width
                return width1 < width2
            }).last else { return }
              
        // 가장 높은 fps 선택
        guard let fps = (format.videoSupportedFrameRateRanges
            .sorted { return $0.maxFrameRate < $1.maxFrameRate })
            .last else { return }

        capturer.startCapture(
            with: frontCamera,
            format: format,
            fps: Int(fps.maxFrameRate)
        )
        
        self.localVideoTrack?.add(renderer)
    }
    
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        self.remoteVideoTrack?.add(renderer)
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            let playAndRecord = AVAudioSession.Category.playAndRecord
            let speaker = AVAudioSession.PortOverride.speaker
            
            try self.rtcAudioSession.setCategory(playAndRecord)
            try self.rtcAudioSession.overrideOutputAudioPort(speaker)
            try self.rtcAudioSession.setActive(true)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        self.peerConnection.add(audioTrack, streamIds: [streamId])
        
        // Video
        let videoTrack = self.createVideoTrack()
        self.localVideoTrack = videoTrack
        self.peerConnection.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = self.peerConnection.transceivers
            .first { $0.mediaType == .video }?
            .receiver.track as? RTCVideoTrack
        
        // Data
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )
        let audioSource = WebRTCClient.peerConnectionFactory.audioSource(
            with: audioConstraints
        )
        let audioTrack = WebRTCClient.peerConnectionFactory.audioTrack(
            with: audioSource,
            trackId: "audio0"
        )
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.peerConnectionFactory.videoSource()
        
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        
        let videoTrack = WebRTCClient.peerConnectionFactory.videoTrack(
            with: videoSource,
            trackId: "video0"
        )
        return videoTrack
    }
    
    // MARK: Data Channels
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = self.peerConnection.dataChannel(
            forLabel: "WebRTCData",
            configuration: config
        ) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        self.remoteDataChannel?.sendData(buffer)
    }
}

// MARK: PeerConnectionDelegate
extension WebRTCClient: RTCPeerConnectionDelegate {
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange stateChanged: RTCSignalingState
    ) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didAdd stream: RTCMediaStream
    ) {
        debugPrint("peerConnection did add stream")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove stream: RTCMediaStream
    ) {
        debugPrint("peerConnection did remove stream")
    }
    
    public func peerConnectionShouldNegotiate(
        _ peerConnection: RTCPeerConnection
    ) {
        debugPrint("peerConnection should negotiate")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceConnectionState
    ) {
        debugPrint("peerConnection new connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceGatheringState
    ) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didGenerate candidate: RTCIceCandidate
    ) {
        self.delegate?.webRTCClient(self, didGenerateLocalCandidate: candidate)
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove candidates: [RTCIceCandidate]
    ) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didOpen dataChannel: RTCDataChannel
    ) {
        debugPrint("peerConnection did open data channel")
        self.remoteDataChannel = dataChannel
    }
}

// MARK: Audio control
extension WebRTCClient {
    func muteAudio() {
        self.setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        self.setAudioEnabled(true)
    }
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }
    
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        peerConnection.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

// MARK: DataChannelDelegate
extension WebRTCClient: RTCDataChannelDelegate {
    public func dataChannelDidChangeState(
        _ dataChannel: RTCDataChannel
    ) {
        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    public func dataChannel(
        _ dataChannel: RTCDataChannel,
        didReceiveMessageWith buffer: RTCDataBuffer
    ) {
        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}
