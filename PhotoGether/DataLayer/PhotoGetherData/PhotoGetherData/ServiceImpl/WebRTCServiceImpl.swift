import Foundation
import Combine
import WebRTC

public final class WebRTCServiceImpl: NSObject, WebRTCService {
    private let didGenerateLocalCandidateSubject = PassthroughSubject<RTCIceCandidate, Never>()
    private let didChangeConnectionStateSubject = PassthroughSubject<RTCIceConnectionState, Never>()
    private let didReceiveDataSubject = PassthroughSubject<Data, Never>()
    
    public var didGenerateLocalCandidatePublisher: AnyPublisher<RTCIceCandidate, Never> {
        self.didGenerateLocalCandidateSubject.eraseToAnyPublisher()
    }
    public var didChangeConnectionStatePublisher: AnyPublisher<RTCIceConnectionState, Never> {
        self.didChangeConnectionStateSubject.eraseToAnyPublisher()
    }
    public var didReceiveDataPublisher: AnyPublisher<Data, Never> {
        self.didReceiveDataSubject.eraseToAnyPublisher()
    }
    
    public var peerConnection: RTCPeerConnection
    
    let streamId = "stream"
    
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let mediaConstraints = [
        kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
        kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue
    ]
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    
    public required init(iceServers: [String]) {
        let config = PeerConnectionSupport.configuration(iceServers: iceServers)
        
        let audioConfig = RTCAudioSessionConfiguration.webRTC()
        audioConfig.category = AVAudioSession.Category.playAndRecord.rawValue
        audioConfig.mode = AVAudioSession.Mode.voiceChat.rawValue
        audioConfig.categoryOptions = [.defaultToSpeaker]
        RTCAudioSessionConfiguration.setWebRTC(audioConfig)
        
        let mediaConstraint = PeerConnectionSupport.mediaConstraint()
        
        guard let peerConnection = PeerConnectionSupport.peerConnectionFactory.peerConnection(
            with: config,
            constraints: mediaConstraint,
            delegate: nil
        ) else {
            PTGDataLogger.log("Could not create new RTCPeerConnection")
            fatalError("Could not create new RTCPeerConnection")
        }
        
        self.peerConnection = peerConnection
        
        super.init()
        
        // MARK: DataChannel 연결
        self.connectDataChannel(dataChannel: createDataChannel())
        
        // MARK: AudioTrack 연결
        let audioTrack = PeerConnectionSupport.createAudioTrack()
        self.connectAudioTrack(audioTrack: audioTrack)
        self.configureAudioSession()
        
        self.peerConnection.delegate = self
    }
}

// MARK: SDP
public extension WebRTCServiceImpl {
    func offer() async throws -> RTCSessionDescription {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: self.mediaConstraints,
            optionalConstraints: nil
        )
        
        // 1. constraints를 통해 내 sdp를 만든다.
        let sdp = try await self.peerConnection.offer(for: constraints)
        
        // 2. sdp를 peerConnection에 저장한다음 소켓을 통해 시그널링 서버를 거쳐 상대에게 전송한다.
        try await self.peerConnection.setLocalDescription(sdp)
        
        return sdp
    }
    
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
    
    func answer() async throws -> RTCSessionDescription {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: self.mediaConstraints,
            optionalConstraints: nil
        )
        
        // 1. constraints를 통해 내 sdp를 만든다.
        let sdp = try await self.peerConnection.answer(for: constraints)
        
        // 2. sdp를 peerConnection에 저장한다음 소켓을 통해 시그널링 서버를 거쳐 상대에게 전송한다.
        try await self.peerConnection.setLocalDescription(sdp)
        
        return sdp
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
    
    func set(remoteSdp: RTCSessionDescription) async throws {
        return try await self.peerConnection.setRemoteDescription(remoteSdp)
    }
    
    func set(localSdp: RTCSessionDescription) async throws {
        return try await self.peerConnection.setLocalDescription(localSdp)
    }
    
    func set(remoteCandidate: RTCIceCandidate) async throws {
        return try await self.peerConnection.add(remoteCandidate)
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
public extension WebRTCServiceImpl {
    /// localVideoTrack에서 수신된 모든 프레임을 렌더링할 렌더러(View)를 등록합니다.
    func renderLocalVideo(to renderer: RTCVideoRenderer) {
        let flippedRenderer = renderer.flipHorizontally()
        self.localVideoTrack?.add(flippedRenderer)
    }
    
    /// remoteVideoTrack에서 수신된 모든 프레임을 렌더링할 렌더러(View)를 등록합니다.
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        let flippedRenderer = renderer.flipHorizontally()
        self.remoteVideoTrack?.add(flippedRenderer)
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: .defaultToSpeaker
            )
            try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
            try self.rtcAudioSession.setActive(true)
        } catch let error {
            PTGDataLogger.log("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }

    func connectAudioTrack(audioTrack: RTCAudioTrack) {
        // Audio
        self.peerConnection.add(audioTrack, streamIds: [streamId])
    }
    
    func connectVideoTrack(videoTrack: RTCVideoTrack) {
        // Video
        self.localVideoTrack = videoTrack
        self.peerConnection.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = self.peerConnection.transceivers
            .first { $0.mediaType == .video }?
            .receiver.track as? RTCVideoTrack
    }
    
    func connectDataChannel(dataChannel: RTCDataChannel?) {
        dataChannel?.delegate = self
        self.localDataChannel = dataChannel
    }
    
    // MARK: Data Channels
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = self.peerConnection.dataChannel(
            forLabel: "WebRTCData",
            configuration: config
        ) else {
            PTGDataLogger.log("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        self.remoteDataChannel?.sendData(buffer)
    }
}

// MARK: Audio control
public extension WebRTCServiceImpl {
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

// MARK: PeerConnectionDelegate
extension WebRTCServiceImpl {
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange stateChanged: RTCSignalingState
    ) {
        PTGDataLogger.log("peerConnection new signaling state: \(stateChanged)")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didAdd stream: RTCMediaStream
    ) {
        PTGDataLogger.log("peerConnection did add stream")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove stream: RTCMediaStream
    ) {
        PTGDataLogger.log("peerConnection did remove stream")
    }
    
    public func peerConnectionShouldNegotiate(
        _ peerConnection: RTCPeerConnection
    ) {
        PTGDataLogger.log("peerConnection should negotiate")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceConnectionState
    ) {
        PTGDataLogger.log("peerConnection new connection state: \(newState)")
        self.didChangeConnectionStateSubject.send(newState)
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceGatheringState
    ) {
        PTGDataLogger.log("peerConnection new gathering state: \(newState)")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didGenerate candidate: RTCIceCandidate
    ) {
        self.didGenerateLocalCandidateSubject.send(candidate)
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove candidates: [RTCIceCandidate]
    ) {
        PTGDataLogger.log("peerConnection did remove candidate(s)")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didOpen dataChannel: RTCDataChannel
    ) {
        PTGDataLogger.log("peerConnection did open data channel")
        self.remoteDataChannel = dataChannel
    }
}

// MARK: DataChannelDelegate
extension WebRTCServiceImpl {
    public func dataChannelDidChangeState(
        _ dataChannel: RTCDataChannel
    ) {
        PTGDataLogger.log("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    public func dataChannel(
        _ dataChannel: RTCDataChannel,
        didReceiveMessageWith buffer: RTCDataBuffer
    ) {
        self.didReceiveDataSubject.send(buffer.data)
    }
}
