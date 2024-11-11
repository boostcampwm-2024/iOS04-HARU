import Foundation
import WebRTC

public final class ConnectionClient {
    private let signalClient: SignalingClient
    private let webRTCClient: WebRTCClient
    
    // TODO: 영상 정보
    // TODO: 음성 정보
    
    public init(signalClient: SignalingClient, webRTCClient: WebRTCClient) {
        self.signalClient = signalClient
        self.webRTCClient = webRTCClient
        
        self.signalClient.delegate = self
        self.webRTCClient.delegate = self
        
        // 서버 자동 연결
        self.connect()
    }
    
    public func connect() {
        self.signalClient.connect()
    }
    
    public func sendData(data: Data) {
        self.webRTCClient.sendData(data)
    }
    
}

extension ConnectionClient: SignalingClientDelegate {
    public func signalClientDidConnect(
        _ signalingClient: SignalingClient
    ) {
        // TODO: 서버 연결 완료 로직 처리
    }
    
    public func signalClientDidDisconnect(
        _ signalingClient: SignalingClient
    ) {
        // TODO: 서버 연결 끊김 로직 처리
    }
    
    public func signalClient(
        _ signalingClient: SignalingClient,
        didReceiveRemoteSdp sdp: RTCSessionDescription
    ) {
        guard self.webRTCClient.peerConnection.remoteDescription == nil else { return }
        
        // TODO: 컴플리션 핸들러 -> async로 리팩토링
        self.webRTCClient.set(remoteSdp: sdp) { error in
            if let error { debugPrint(error) }
            
            guard self.webRTCClient.peerConnection.localDescription == nil else { return }
            
            self.webRTCClient.answer { sdp in
                self.signalClient.send(sdp: sdp)
            }
        }
    }
    
    public func signalClient(
        _ signalingClient: SignalingClient,
        didReceiveCandidate candidate: RTCIceCandidate
    ) {
        self.webRTCClient.set(remoteCandidate: candidate) { _ in }
    }
}

extension ConnectionClient: WebRTCClientDelegate {
    /// SDP 가 생성되면 LocalCandidate 가 생성되기 시작 (가능한 경로만큼 생성됨)
    public func webRTCClient(
        _ client: WebRTCClient,
        didGenerateLocalCandidate candidate: RTCIceCandidate
    ) {
        self.signalClient.send(candidate: candidate)
    }
    
    public func webRTCClient(
        _ client: WebRTCClient,
        didChangeConnectionState state: RTCIceConnectionState
    ) {
        // TODO: 피어커넥션 연결 상태 변경에 따른 처리
    }
    
    public func webRTCClient(
        _ client: WebRTCClient,
        didReceiveData data: Data
    ) {
        // TODO: 수신된 데이터를 처리하는 곳
    }
    
    
}
