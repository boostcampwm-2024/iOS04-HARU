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
        // MARK: 이미 방에 있던 놈들이 받는 이벤트
        self.signalingService.didReceiveOfferSdpPublisher
            .filter { [weak self] _ in self?.remoteUserInfo != nil }
            .sink { [weak self] remoteSDP in
                
                PTGDataLogger.log("didReceiveRemoteSdpPublisher sink!! \(remoteSDP)")
                
                // MARK: remoteDescription이 있으면 이미 연결된 클라이언트
                guard self?.webRTCService.peerConnection.remoteDescription == nil else {
                    PTGDataLogger.log("remoteSDP가 이미 있어요!")
                    return
                }
                PTGDataLogger.log("remoteSDP가 없어요! remoteSDP 저장하기 직전")
                guard let userInfo = self?.remoteUserInfo else {
                    PTGDataLogger.log("answer를 받을 remote User가 없어요!! 비상!!!")
                    return
                }
                guard self?.webRTCService.peerConnection.localDescription == nil else {
                    PTGDataLogger.log("localSDP가 이미 있어요!")
                    return
                }
                
            self?.webRTCService.set(remoteSdp: remoteSDP) { error in
                PTGDataLogger.log("remoteSDP가 저장되었어요!")

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
