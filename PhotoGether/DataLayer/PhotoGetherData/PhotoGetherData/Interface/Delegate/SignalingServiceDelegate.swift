import Foundation
import WebRTC

public protocol SignalingServiceDelegate: AnyObject {
    func signalingServiceDidConnect(_ signalingService: SignalingService)
    func signalingServiceDidDisconnect(_ signalingService: SignalingService)
    func signalingService(_ signalingService: SignalingService, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalingService(_ signalingService: SignalingService, didReceiveCandidate candidate: RTCIceCandidate)
}
