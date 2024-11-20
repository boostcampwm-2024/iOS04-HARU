import Foundation
import WebRTC

public protocol SignalingClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalingClient: SignalingService)
    func signalClientDidDisconnect(_ signalingClient: SignalingService)
    func signalClient(_ signalingClient: SignalingService, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalingClient: SignalingService, didReceiveCandidate candidate: RTCIceCandidate)
}
