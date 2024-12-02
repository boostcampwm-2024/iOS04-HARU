import Foundation
import WebRTC
import Combine
import PhotoGetherDomainInterface

public final class ConnectionClientImpl: ConnectionClient {
    private var cancellables: Set<AnyCancellable> = []
    
    private let webRTCService: WebRTCService
    
    private let receivedDataSubject = PassthroughSubject<Data, Never>()
    private let didGenerateLocalCandidateSubejct = PassthroughSubject<(receiverID: String, RTCIceCandidate), Never>()
    
    public var receivedDataPublisher: AnyPublisher<Data, Never> {
        receivedDataSubject.eraseToAnyPublisher()
    }
    public var didGenerateLocalCandidatePublisher: AnyPublisher<(receiverID: String, RTCIceCandidate), Never> {
        didGenerateLocalCandidateSubejct.eraseToAnyPublisher()
    }
    public var remoteVideoView: UIView = CapturableVideoView()
    public var remoteUserInfo: UserInfo?
        
    public init(
        webRTCService: WebRTCService,
        remoteUserInfo: UserInfo? = nil
    ) {
        self.webRTCService = webRTCService
        self.remoteUserInfo = remoteUserInfo
        
        bindWebRTCService()
                
        // VideoTrack과 나와 상대방의 화면을 볼 수 있는 뷰를 바인딩합니다.
        self.bindRemoteVideo()
    }
    
    public func setRemoteUserInfo(_ remoteUserInfo: UserInfo) {
        self.remoteUserInfo = remoteUserInfo
    }
    
    /// 해당 클라이언트에게 보낼 Offer SDP를 생성합니다.
    public func createOffer() async throws -> RTCSessionDescription {
        guard remoteUserInfo != nil else { throw NSError() }
        return try await self.webRTCService.offer()
    }
    
    /// 해당 클라이언트에게 보낼 Answer SDP를 생성합니다.
    public func createAnswer() async throws -> RTCSessionDescription {
        guard remoteUserInfo != nil else { throw NSError() }
        return try await self.webRTCService.answer()
    }
    
    /// 해당 클라이언트에게 WebRTC DataChannel을 통해 데이터를 전송합니다.
    public func sendData(data: Data) {
        self.webRTCService.sendData(data)
    }
    
    public func set(remoteSdp: RTCSessionDescription) async throws {
        try await self.webRTCService.set(remoteSdp: remoteSdp)
    }
    public func set(localSdp: RTCSessionDescription) async throws {
        try await self.webRTCService.set(localSdp: localSdp)
    }
    public func set(remoteCandidate: RTCIceCandidate) async throws {
        try await self.webRTCService.set(remoteCandidate: remoteCandidate)
    }
    
    public func captureVideo() -> UIImage {
        guard let videoView = self.remoteVideoView as? CapturableVideoView else {
            return UIImage()
        }
        
        guard let capturedImage = videoView.capture() else {
            return UIImage()
        }
        
        return capturedImage
    }
    
    /// remoteVideoTrack과 상대방의 화면을 볼 수 있는 뷰를 바인딩합니다.
    public func bindRemoteVideo() {
        guard let remoteVideoView = remoteVideoView as? RTCMTLVideoView else { return }
        self.webRTCService.connectRemoteVideoTrack()
        let flipedRemoteVideoView = remoteVideoView.flipHorizontally() // 기본이 전면카메라이므로 좌우반전으로 시작
        self.webRTCService.renderRemoteVideo(to: flipedRemoteVideoView)
    }
    
    public func bindLocalVideo(videoSource: RTCVideoSource?, _ localVideoView: UIView) {
        guard let videoSource else { return }
        let videoTrack = PeerConnectionSupport.createVideoTrack(videoSource: videoSource)
        guard let localVideoView = localVideoView as? RTCMTLVideoView else { return }
        
        self.webRTCService.connectLocalVideoTrack(videoTrack: videoTrack)
        self.webRTCService.renderLocalVideo(to: localVideoView)
    }
        
    private func bindWebRTCService() {
        self.webRTCService.didReceiveDataPublisher.sink { [weak self] data in
            guard let self else { return }
            receivedDataSubject.send(data)
        }.store(in: &cancellables)
        
        self.webRTCService.didGenerateLocalCandidatePublisher.sink { [weak self] candidate in
            guard let self, let remoteUserInfo else { return }
            self.didGenerateLocalCandidateSubejct.send((receiverID: remoteUserInfo.id, candidate))
        }.store(in: &cancellables)
    }
}
