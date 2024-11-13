import Foundation
import WebRTC

public protocol SignalingClient: WebSocketClientDelegate {
    var delegate: SignalingClientDelegate? { get }
    
    func connect()
    func send(sdp rtcSdp: RTCSessionDescription)
    func send(candidate rtcIceCandidate: RTCIceCandidate)
}
