import Foundation
import Combine
import WebRTC
import PhotoGetherNetwork

public protocol SignalingService: WebSocketClientDelegate {
    var didConnectPublisher: AnyPublisher<Void, Never> { get }
    var didDidDisconnectPublisher: AnyPublisher<Void, Never> { get }
    var didReceiveOfferSdpPublisher: AnyPublisher<SessionDescriptionMessage, Never> { get }
    var didReceiveAnswerSdpPublisher: AnyPublisher<SessionDescriptionMessage, Never> { get }
    var didReceiveCandidatePublisher: AnyPublisher<IceCandidateMessage, Never> { get }
    
    func connect()
    func send(
        type: SignalingRequestDTO.SignalingMessageType,
        sdp: RTCSessionDescription,
        roomID: String,
        offerID: String,
        answerID: String?
    )
    func send(
        type: SignalingRequestDTO.SignalingMessageType,
        candidate: RTCIceCandidate,
        roomID: String,
        receiverID: String,
        senderID: String
    )
}
