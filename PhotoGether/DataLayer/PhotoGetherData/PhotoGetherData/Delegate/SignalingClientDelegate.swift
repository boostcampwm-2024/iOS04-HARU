import Foundation
import WebRTC

public protocol SignalingClientDelegate: AnyObject {
    func signalClientDidConnect(_ signalingClient: SignalingClient)
    func signalClientDidDisconnect(_ signalingClient: SignalingClient)
    func signalClient(_ signalingClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalingClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}
