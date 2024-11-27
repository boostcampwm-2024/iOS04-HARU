import Foundation
import WebRTC
import Combine
import PhotoGetherDomainInterface

public final class ConnectionClientImpl: ConnectionClient {
    private var cancellables: Set<AnyCancellable> = []
    
    private let signalingService: SignalingService
    private let webRTCService: WebRTCService
    
    public var receivedDataPublisher = PassthroughSubject<Data, Never>()
    
    public var remoteVideoView: UIView = CapturableVideoView()
    public var remoteUserInfo: UserInfo?
        
    public init(
        signalingService: SignalingService,
        webRTCService: WebRTCService,
        remoteUserInfo: UserInfo? = nil
    ) {
        self.signalingService = signalingService
        self.webRTCService = webRTCService
        self.remoteUserInfo = remoteUserInfo
        
        bindSignalingService()
        bindWebRTCService()
        
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
    
    private func bindSignalingService() {
        self.signalingService.didReceiveRemoteSdpPublisher.sink { [weak self] sdp in
            guard let self else { return }
            
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
        }.store(in: &cancellables)
        
        self.signalingService.didReceiveCandidatePublisher.sink { [weak self] candidate in
            guard let self else { return }
            self.webRTCService.set(remoteCandidate: candidate) { _ in }
        }.store(in: &cancellables)
    }
    
    private func bindWebRTCService() {
        self.webRTCService.didReceiveDataPublisher.sink { [weak self] data in
            guard let self else { return }
            receivedDataPublisher.send(data)
        }.store(in: &cancellables)
        
        self.webRTCService.didGenerateLocalCandidatePublisher.sink { [weak self] candidate in
            guard let self, let remoteUserInfo else { return }
            self.signalingService.send(
                type: .iceCandidate,
                candidate: candidate,
                userID: remoteUserInfo.id,
                roomID: remoteUserInfo.roomID
            )
        }.store(in: &cancellables)
    }
}
