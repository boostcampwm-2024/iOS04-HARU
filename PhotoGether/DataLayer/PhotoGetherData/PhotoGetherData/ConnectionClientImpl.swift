import Foundation
import WebRTC
import Combine
import PhotoGetherDomainInterface

public final class ConnectionClientImpl: ConnectionClient {
    private let signalingService: SignalingService
    private let webRTCService: WebRTCService
    
    public var receivedDataPublisher = PassthroughSubject<Data, Never>()
    
    public var remoteVideoView: UIView = CapturableVideoView()
    public var remoteUserInfo: UserInfo?
    
    public var roomID: String = ""
    
    public init(
        signalingService: SignalingService,
        webRTCService: WebRTCService,
        remoteUserInfo: UserInfo? = nil
    ) {
        self.signalingService = signalingService
        self.webRTCService = webRTCService
        self.remoteUserInfo = remoteUserInfo
        
        self.signalingService.delegate = self
        self.webRTCService.delegate = self
        
        // 서버 자동 연결
        self.connect()
        
        // VideoTrack과 나와 상대방의 화면을 볼 수 있는 뷰를 바인딩합니다.
        self.bindRemoteVideo()
    }
    
    public func setRemoteUserInfo(_ remoteUserInfo: UserInfo) {
        self.remoteUserInfo = remoteUserInfo
    }
    
    public func sendOffer(myID: String) {
        guard let remoteUserInfo else { return }
        
        self.webRTCService.offer { sdp in
            self.signalingService.send(
                type: .offerSDP,
                sdp: sdp,
                userID: myID,
                roomID: remoteUserInfo.roomID
            )
        }
    }
    
    public func sendData(data: Data) {
        self.webRTCService.sendData(data)
    }
    
    public func captureVideo() -> UIImage {
        guard let videoView = self.remoteVideoView as? CapturableVideoView else {
            return UIImage()
        }
        
        guard let capturedImage = videoView.capturedImage else {
            return UIImage()
        }
        
        return capturedImage
    }
    
    private func connect() {
        self.signalingService.connect()
    }
    
    /// remoteVideoTrack과 상대방의 화면을 볼 수 있는 뷰를 바인딩합니다.
    private func bindRemoteVideo() {
        guard let remoteVideoView = remoteVideoView as? RTCMTLVideoView else { return }
        self.webRTCService.renderRemoteVideo(to: remoteVideoView)
    }
    
    public func bindLocalVideo(_ localVideoView: UIView) {
        guard let localVideoView = localVideoView as? RTCMTLVideoView else { return }
        self.webRTCService.startCaptureLocalVideo(renderer: localVideoView)
    }
}

// MARK: SignalingClientDelegate
extension ConnectionClientImpl: SignalingServiceDelegate {
    public func signalingServiceDidConnect(
        _ signalingService: SignalingService
    ) {
        // TODO: 서버 연결 완료 로직 처리
    }
    
    public func signalingServiceDidDisconnect(
        _ signalingService: SignalingService
    ) {
        // TODO: 서버 연결 끊김 로직 처리
    }
    
    public func signalingService(
        _ signalingService: SignalingService,
        didReceiveRemoteSdp sdp: RTCSessionDescription
    ) {
        guard self.webRTCService.peerConnection.remoteDescription == nil else { return }
        
        self.webRTCService.set(remoteSdp: sdp) { error in
            if let error { PTGDataLogger.log(error.localizedDescription) }
            
            guard self.webRTCService.peerConnection.localDescription == nil else { return }
            
            self.webRTCService.answer { sdp in
                guard let userInfo = self.remoteUserInfo else { return }
                
                self.signalingService.send(
                    type: .answerSDP,
                    sdp: sdp,
                    userID: userInfo.id,
                    roomID: userInfo.roomID
                )
            }
        }
    }
    
    public func signalingService(
        _ signalingService: SignalingService,
        didReceiveCandidate candidate: RTCIceCandidate
    ) {
        self.webRTCService.set(remoteCandidate: candidate) { _ in }
    }
}

// MARK: WebRTCClientDelegate
extension ConnectionClientImpl: WebRTCServiceDelegate {
    /// SDP 가 생성되면 LocalCandidate 가 생성되기 시작 (가능한 경로만큼 생성됨)
    public func webRTCService(
        _ service: WebRTCService,
        didGenerateLocalCandidate candidate: RTCIceCandidate
    ) {
        guard let remoteUserInfo else { return }
        
        self.signalingService.send(
            type: .iceCandidate,
            candidate: candidate,
            userID: remoteUserInfo.id,
            roomID: remoteUserInfo.roomID
        )
    }
    
    public func webRTCService(
        _ service: WebRTCService,
        didChangeConnectionState state: RTCIceConnectionState
    ) {
        // TODO: 피어커넥션 연결 상태 변경에 따른 처리
    }
    
    /// peerConnection의 remoteDataChannel 에 데이터가 수신되면 호출됨
    public func webRTCService(
        _ service: WebRTCService,
        didReceiveData data: Data
    ) {
        receivedDataPublisher.send(data)
    }
}
