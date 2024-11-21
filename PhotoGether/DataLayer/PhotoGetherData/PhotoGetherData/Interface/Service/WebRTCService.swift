import Foundation
import WebRTC

public protocol WebRTCService: RTCPeerConnectionDelegate, RTCDataChannelDelegate {
    var delegate: WebRTCServiceDelegate? { get set }
    var peerConnection: RTCPeerConnection { get }
    
    // MARK: SDP
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void)
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void)
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> Void)
    func set(localSdp: RTCSessionDescription, completion: @escaping (Error?) -> Void)
    func set(remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> Void)
    
    // MARK: Video
    func startCaptureLocalVideo(renderer: RTCVideoRenderer)
    func renderRemoteVideo(to renderer: RTCVideoRenderer)
    
    // MARK: Data
    func sendData(_ data: Data)
    
    // MARK: Audio
    func muteAudio()
    func unmuteAudio()
}
