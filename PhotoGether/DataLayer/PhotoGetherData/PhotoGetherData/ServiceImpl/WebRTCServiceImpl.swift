import Foundation
import Combine
import WebRTC
import CoreModule

public final class WebRTCServiceImpl: NSObject, WebRTCService {
    private var cancellables: Set<AnyCancellable> = []
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
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
    private var localAudioTrack: RTCAudioTrack
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    
    public required init(iceServers: [String]) {
        let config = PeerConnectionSupport.configuration(iceServers: iceServers)
        
        let audioConfig = RTCAudioSessionConfiguration.webRTC()
        audioConfig.category = AVAudioSession.Category.playAndRecord.rawValue
        audioConfig.mode = AVAudioSession.Mode.voiceChat.rawValue
        audioConfig.categoryOptions = [
            .defaultToSpeaker, // 하단 스피커를 기본으로 설정
            .allowBluetooth, // 블루투스 기기의 음성 입출력 지원
            .allowAirPlay // AirPlay를 통해 연결된 다른 기기로 음성 출력 지원
        ]
        RTCAudioSessionConfiguration.setWebRTC(audioConfig)
        
        let mediaConstraint = PeerConnectionSupport.mediaConstraint()
        
        guard let peerConnection = PeerConnectionSupport.peerConnectionFactory.peerConnection(
            with: config,
            constraints: mediaConstraint,
            delegate: nil
        ) else {
            PTGLogger.default.log("Could not create new RTCPeerConnection")
            fatalError("Could not create new RTCPeerConnection")
        }
        
        self.peerConnection = peerConnection
        // MARK: AudioTrack 생성
        self.localAudioTrack = PeerConnectionSupport.createAudioTrack()
        
        super.init()
        
        // MARK: DataChannel 연결
        self.connectDataChannel(dataChannel: createDataChannel())
        
        // MARK: AudioTrack 연결
        self.connectAudioTrack(audioTrack: self.localAudioTrack)
        self.configureAudioSession()
        
        self.peerConnection.delegate = self
        self.bindNoti()
    }
    
    private func bindNoti() {
        NotificationCenter.default.publisher(for: .navigateToPhotoRoom).sink { [weak self] noti in
            guard let self else { return }
            guard let message = SyncNotification(name: "navigateToPhotoRoom").toData(encoder: self.encoder) else { return }
            self.sendData(message)
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .startCountDown).sink { [weak self] noti in
            guard let self else { return }
            guard let message = SyncNotification(name: "startCountDown").toData(encoder: self.encoder) else { return }
            self.sendData(message)
        }.store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .navigateToShareRoom).sink { [weak self] noti in
            guard let self else { return }
            guard let message = SyncNotification(name: "navigateToShareRoom").toData(encoder: self.encoder) else { return }
            self.sendData(message)
        }.store(in: &cancellables)
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
        PTGLogger.default.log("\(self.remoteVideoTrack?.description ?? "nil")")
        self.remoteVideoTrack?.add(flippedRenderer)
    }
    
    func connectLocalVideoTrack(videoTrack: RTCVideoTrack) {
        self.localVideoTrack = videoTrack
        self.peerConnection.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = self.peerConnection.transceivers
            .first { $0.mediaType == .video }?
            .receiver.track as? RTCVideoTrack
    }
    
    func connectRemoteVideoTrack() {
        self.remoteVideoTrack = self.peerConnection.transceivers
            .first { $0.mediaType == .video }?
            .receiver.track as? RTCVideoTrack
        PTGLogger.default.log("\(remoteVideoTrack?.description ?? "nil")")
    }
    
    private func connectAudioTrack(audioTrack: RTCAudioTrack) {
        // Audio
        self.peerConnection.add(audioTrack, streamIds: [streamId])
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            
            try self.rtcAudioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: .defaultToSpeaker
            )
            try self.rtcAudioSession.setActive(true)
        } catch let error {
            PTGLogger.default.log("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func connectDataChannel(dataChannel: RTCDataChannel?) {
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
            PTGLogger.default.log("Warning: Couldn't create data channel.")
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
    
    func changeLocalAudioState(_ isEnabled: Bool) {
        self.localAudioTrack.isEnabled = isEnabled
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
        PTGLogger.default.log("peerConnection new signaling state: \(stateChanged)")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didAdd stream: RTCMediaStream
    ) {
        PTGLogger.default.log("peerConnection did add stream")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didRemove stream: RTCMediaStream
    ) {
        PTGLogger.default.log("peerConnection did remove stream")
    }
    
    public func peerConnectionShouldNegotiate(
        _ peerConnection: RTCPeerConnection
    ) {
        PTGLogger.default.log("peerConnection should negotiate")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceConnectionState
    ) {
        PTGLogger.default.log("peerConnection new connection state: \(newState)")
        self.didChangeConnectionStateSubject.send(newState)
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didChange newState: RTCIceGatheringState
    ) {
        PTGLogger.default.log("peerConnection new gathering state: \(newState)")
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
        PTGLogger.default.log("peerConnection did remove candidate(s)")
    }
    
    public func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didOpen dataChannel: RTCDataChannel
    ) {
        PTGLogger.default.log("peerConnection did open data channel")
        self.remoteDataChannel = dataChannel
    }
}

// MARK: DataChannelDelegate
extension WebRTCServiceImpl {
    public func dataChannelDidChangeState(
        _ dataChannel: RTCDataChannel
    ) {
        PTGLogger.default.log("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    public func dataChannel(
        _ dataChannel: RTCDataChannel,
        didReceiveMessageWith buffer: RTCDataBuffer
    ) {
        self.didReceiveDataSubject.send(buffer.data)
        
        if let tempNoti = buffer.data.toDTO(type: SyncNotification.self, decoder: decoder) {
            switch tempNoti.name {
            case "navigateToPhotoRoom":
                NotificationCenter.default.post(name: .receiveNavigateToPhotoRoom, object: nil)
            case "startCountDown":
                NotificationCenter.default.post(name: .receiveStartCountDown, object: nil)
            case "navigateToShareRoom":
                NotificationCenter.default.post(name: .receiveNavigateToShareRoom, object: nil)
            default:
                break
            }
        }

    }
}

struct SyncNotification: Codable {
    let name: String
}
