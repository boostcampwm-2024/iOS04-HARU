import Foundation
import Combine
import WebRTC
import PhotoGetherNetwork
import CoreModule

final public class SignalingServiceImpl: SignalingService {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var webSocketClient: WebSocketClient
    
    private let didConnectSubject = PassthroughSubject<Void, Never>()
    private let didDisconnectSubject = PassthroughSubject<Void, Never>()
    private let didReceiveOfferSdpSubject = PassthroughSubject<SessionDescriptionMessage, Never>()
    private let didReceiveAnswerSdpSubject = PassthroughSubject<SessionDescriptionMessage, Never>()
    private let didReceiveCandidateSubject = PassthroughSubject<IceCandidateMessage, Never>()
    
    public var didConnectPublisher: AnyPublisher<Void, Never> {
        self.didConnectSubject.eraseToAnyPublisher()
    }
    public var didDidDisconnectPublisher: AnyPublisher<Void, Never> {
        self.didDisconnectSubject.eraseToAnyPublisher()
    }
    public var didReceiveOfferSdpPublisher: AnyPublisher<SessionDescriptionMessage, Never> {
        self.didReceiveOfferSdpSubject.eraseToAnyPublisher()
    }
    public var didReceiveAnswerSdpPublisher: AnyPublisher<SessionDescriptionMessage, Never> {
        self.didReceiveAnswerSdpSubject.eraseToAnyPublisher()
    }
    public var didReceiveCandidatePublisher: AnyPublisher<IceCandidateMessage, Never> {
        self.didReceiveCandidateSubject.eraseToAnyPublisher()
    }
    
    public init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
        self.webSocketClient.delegates.append(self) 
    }
    
    public func connect() {
        self.webSocketClient.connect()
    }
    
    public func send(
        type: SignalingRequestDTO.SignalingMessageType,
        sdp: RTCSessionDescription,
        roomID: String,
        offerID: String,
        answerID: String?
    ) {
        PTGLogger.default.log("send SDP type: \(type) roomID: \(roomID) offerID: \(offerID) answerID: \(answerID ?? "nil")")
        let message = SessionDescriptionMessage(from: sdp, roomID: roomID, offerID: offerID, answerID: answerID)
        do {
            let dataMessage = try self.encoder.encode(message)
            let dto = SignalingRequestDTO(messageType: type, message: dataMessage)
            let request = try self.encoder.encode(dto)    
            self.webSocketClient.send(data: dataMessage)
        } catch {
            PTGLogger.default.log("Warning: Could not encode sdp: \(error)")
        }
    }
    
    public func send(
        type: SignalingRequestDTO.SignalingMessageType,
        candidate: RTCIceCandidate,
        roomID: String,
        receiverID: String,
        senderID: String
    ) {
        let message = IceCandidateMessage(from: candidate, receiverID: receiverID, senderID: senderID, roomID: roomID)
        do {
            let dataMessage = try self.encoder.encode(message)
            let dto = SignalingRequestDTO(messageType: type, message: dataMessage)
            let request = try self.encoder.encode(dto)
            self.webSocketClient.send(data: dataMessage)
        } catch {
            PTGLogger.default.log("Warning: Could not encode candidate: \(error)")
        }
    }
}

// MARK: WebSocketClientDelegate
extension SignalingServiceImpl {
    public func webSocketDidConnect(_ webSocket: WebSocketClient) {
        self.didConnectSubject.send(())
    }
    
    public func webSocketDidDisconnect(_ webSocket: WebSocketClient) {
        self.didDisconnectSubject.send(())
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            PTGLogger.default.log("Signaling server 재연결 시도 중...")
            self.webSocketClient.connect()
        }
    }
    
    public func webSocket(_ webSocket: WebSocketClient, didReceiveData data: Data) {
        guard let response = data.toDTO(type: SignalingResponseDTO.self, decoder: decoder) else { return }
        switch response.messageType {
        case .iceCandidate:
            guard let iceCandidate = response.message?.toDTO(type: IceCandidateMessage.self, decoder: decoder)
            else { return }
            self.didReceiveCandidateSubject.send(iceCandidate)
        
        case .offerSDP:
            guard let sdp = response.message?.toDTO(type: SessionDescriptionMessage.self, decoder: decoder)
            else { return }
            PTGLogger.default.log("Received Offer SDP: \(sdp)")
            self.didReceiveOfferSdpSubject.send(sdp)
            
        case .answerSDP:
            guard let sdp = response.message?.toDTO(type: SessionDescriptionMessage.self, decoder: decoder)
            else { return }
            PTGLogger.default.log("Received Answer SDP: \(sdp)")
            self.didReceiveAnswerSdpSubject.send(sdp)
        
        @unknown default:
            PTGLogger.default.log("Unknown Message Type: \(response)")
            return
        }
    }
}
