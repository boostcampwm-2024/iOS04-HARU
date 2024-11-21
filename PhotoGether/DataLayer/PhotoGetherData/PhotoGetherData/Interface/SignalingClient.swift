import Foundation
import WebRTC
import PhotoGetherNetwork

public protocol SignalingClient: WebSocketClientDelegate {
    var delegate: SignalingClientDelegate? { get set }
    
    func connect()
    func send(sdp rtcSdp: RTCSessionDescription)
    func send(candidate rtcIceCandidate: RTCIceCandidate)
}
