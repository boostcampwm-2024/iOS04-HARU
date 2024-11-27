import Foundation
import WebRTC
import PhotoGetherNetwork

final public class SignalingServiceImpl: SignalingService {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var webSocketClient: WebSocketClient
    public var delegate: SignalingServiceDelegate?
    
    public init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
        self.webSocketClient.delegates.append(self) 
    }
    
    public func connect() {
        self.webSocketClient.connect()
    }
    
    public func send(sdp rtcSdp: RTCSessionDescription, userID: String, roomID: String) {
        let message = SessionDescriptionMessage(from: rtcSdp, userID: userID, roomID: roomID)
        do {
            let dataMessage = try self.encoder.encode(message)
            let dto = SignalingRequestDTO(messageType: .sdp, message: dataMessage)
            let request = try self.encoder.encode(dto)
            
            self.webSocketClient.send(data: request)
        } catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    public func send(candidate rtcIceCandidate: RTCIceCandidate, userID: String, roomID: String) {
        let message = IceCandidateMessage(from: rtcIceCandidate, userID: userID, roomID: roomID)
        do {
            let dataMessage = try self.encoder.encode(message)
            let dto = SignalingRequestDTO(messageType: .iceCandidate, message: dataMessage)
            let request = try self.encoder.encode(dto)
            
            self.webSocketClient.send(data: request)
        } catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
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
            debugPrint("Signaling server 재연결 시도 중...")
            self.webSocketClient.connect()
        }
    }
    
    public func webSocket(_ webSocket: WebSocketClient, didReceiveData data: Data) {
        guard let response = data.toDTO(type: SignalingResponseDTO.self, decoder: decoder)
        else {
            debugPrint("수신한 메시지 decoding에 실패하였습니다.: \(data)")
            return
        }
        
        switch response.messageType {
        case .iceCandidate:
            guard let iceCandidate = response.message?.toDTO(type: IceCandidateMessage.self, decoder: decoder)
            else {
                debugPrint("IceCandidate decoding에 실패하였습니다.: \(response)")
                return
            }
            self.delegate?.signalingService(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp:
            guard let sdp = response.message?.toDTO(type: SessionDescriptionMessage.self, decoder: decoder)
            else {
                debugPrint("SDP decoding에 실패하였습니다.: \(response)")
                return
            }
            self.delegate?.signalingService(self, didReceiveRemoteSdp: sdp.rtcSessionDescription)
        @unknown default:
            debugPrint("Unknown Message Type: \(response)")
            return
        }
    }
}
