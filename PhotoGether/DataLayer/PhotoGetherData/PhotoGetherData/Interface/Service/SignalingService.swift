import Foundation
import WebRTC
import PhotoGetherNetwork

public protocol SignalingService: WebSocketClientDelegate {
    var delegate: SignalingServiceDelegate? { get set }
    
    func connect()
    func send(
        type: SignalingRequestDTO.SignalingMessageType,
        sdp rtcSdp: RTCSessionDescription,
        userID: String,
        roomID: String
    )
    func send(
        type: SignalingRequestDTO.SignalingMessageType,
        candidate rtcIceCandidate: RTCIceCandidate,
        userID: String,
        roomID: String
    )
}
