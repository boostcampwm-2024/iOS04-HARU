import Foundation
import Combine
import WebRTC
import PhotoGetherNetwork

public protocol SignalingService: WebSocketClientDelegate {
    var didConnectPublisher: AnyPublisher<Void, Never> { get }
    var didDidDisconnectPublisher: AnyPublisher<Void, Never> { get }
    var didReceiveRemoteSdpPublisher: AnyPublisher<RTCSessionDescription, Never> { get }
    var didReceiveCandidatePublisher: AnyPublisher<RTCIceCandidate, Never> { get }
    
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
