import Foundation
import Combine
import WebRTC
import PhotoGetherNetwork

final public class SignalingServiceImpl: SignalingService {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var webSocketClient: WebSocketClient
    public var delegate: SignalingServiceDelegate?
    
    private let didConnectSubject = PassthroughSubject<Void, Never>()
    private let didDisconnectSubject = PassthroughSubject<Void, Never>()
    private let didReceiveRemoteSdpSubject = PassthroughSubject<RTCSessionDescription, Never>()
    private let didReceiveCandidateSubject = PassthroughSubject<RTCIceCandidate, Never>()
    
    public var didConnectPublisher: AnyPublisher<Void, Never> {
        self.didConnectSubject.eraseToAnyPublisher()
    }
    public var didDidDisconnectPublisher: AnyPublisher<Void, Never> {
        self.didDisconnectSubject.eraseToAnyPublisher()
    }
    public var didReceiveRemoteSdpPublisher: AnyPublisher<RTCSessionDescription, Never> {
        self.didReceiveRemoteSdpSubject.eraseToAnyPublisher()
    }
    public var didReceiveCandidatePublisher: AnyPublisher<RTCIceCandidate, Never> {
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
        sdp rtcSdp: RTCSessionDescription,
        userID: String,
        roomID: String
    ) {
        PTGDataLogger.log("send SDP type: \(type) userID: \(userID) roomID: \(roomID)")
        let message = SessionDescriptionMessage(from: rtcSdp, userID: userID, roomID: roomID)
        do {
            let dataMessage = try self.encoder.encode(message)
            let dto = SignalingRequestDTO(messageType: type, message: dataMessage)
            let request = try self.encoder.encode(dto)
            
            self.webSocketClient.send(data: request)
        } catch {
            PTGDataLogger.log("Warning: Could not encode sdp: \(error)")
        }
    }
    
    public func send(
        type: SignalingRequestDTO.SignalingMessageType,
        candidate rtcIceCandidate: RTCIceCandidate,
        userID: String,
        roomID: String
    ) {
        PTGDataLogger.log("send Candidate type: \(type) userID: \(userID) roomID: \(roomID)")
        let message = IceCandidateMessage(from: rtcIceCandidate, userID: userID, roomID: roomID)
        do {
            let dataMessage = try self.encoder.encode(message)
            let dto = SignalingRequestDTO(messageType: type, message: dataMessage)
            let request = try self.encoder.encode(dto)
            
            self.webSocketClient.send(data: request)
        } catch {
            PTGDataLogger.log("Warning: Could not encode candidate: \(error)")
        }
    }
}

// MARK: WebSocketClientDelegate
extension SignalingServiceImpl {
    public func webSocketDidConnect(_ webSocket: WebSocketClient) {
        self.delegate?.signalingServiceDidConnect(self)
    }
    
    public func webSocketDidDisconnect(_ webSocket: WebSocketClient) {
        self.delegate?.signalingServiceDidDisconnect(self)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            PTGDataLogger.log("Signaling server 재연결 시도 중...")
            self.webSocketClient.connect()
        }
    }
    
    public func webSocket(_ webSocket: WebSocketClient, didReceiveData data: Data) {
        guard let response = data.toDTO(type: SignalingResponseDTO.self, decoder: decoder)
        else {
            PTGDataLogger.log("수신한 메시지 decoding에 실패하였습니다.: \(data)")
            return
        }
        PTGDataLogger.log("Signaling 응답 수신.: \(response.messageType)")
        switch response.messageType {
        case .iceCandidate:
            guard let iceCandidate = response.message?.toDTO(type: IceCandidateMessage.self, decoder: decoder)
            else {
                PTGDataLogger.log("IceCandidate decoding에 실패하였습니다.: \(response)")
                return
            }
            PTGDataLogger.log("iceCandidate 응답 수신.\(String(describing: self.delegate))")
            self.delegate?.signalingService(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .offerSDP:
            guard let sdp = response.message?.toDTO(type: SessionDescriptionMessage.self, decoder: decoder)
            else {
                PTGDataLogger.log("SDP decoding에 실패하였습니다.: \(response)")
                return
            }
            PTGDataLogger.log("offerSDP 응답 수신.\(String(describing: self.delegate))")
            self.delegate?.signalingService(self, didReceiveRemoteSdp: sdp.rtcSessionDescription)
            
        case .answerSDP:
            guard let sdp = response.message?.toDTO(type: SessionDescriptionMessage.self, decoder: decoder)
            else {
                PTGDataLogger.log("SDP decoding에 실패하였습니다.: \(response)")
                return
            }
            PTGDataLogger.log("answerSDP 응답 수신.\(String(describing: self.delegate))")
            self.delegate?.signalingService(self, didReceiveRemoteSdp: sdp.rtcSessionDescription)
        @unknown default:
            PTGDataLogger.log("Unknown Message Type: \(response)")
            return
        }
    }
}
