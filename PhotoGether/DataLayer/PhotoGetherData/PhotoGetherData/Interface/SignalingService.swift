import Foundation
import WebRTC
import PhotoGetherNetwork

public protocol SignalingService: WebSocketClientDelegate {
    var delegate: SignalingClientDelegate? { get set }
    
    func connect()
    func send(sdp rtcSdp: RTCSessionDescription, peerID: String, roomID: String)
    func send(candidate rtcIceCandidate: RTCIceCandidate, peerID: String, roomID: String)
}
