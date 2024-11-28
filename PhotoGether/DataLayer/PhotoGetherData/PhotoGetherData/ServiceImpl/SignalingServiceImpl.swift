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
    
    public func send(sdp rtcSdp: RTCSessionDescription, peerID: String, roomID: String) {
        let message = SignalingMessage.sdp(SessionDescription(from: rtcSdp, peerID: peerID, roomID: roomID))
        do {
            let dataMessage = try self.encoder.encode(message)
            let dto = SignalingRequestDTO(messageType: .signaling, message: dataMessage)
            let request = try self.encoder.encode(dto)
            
            self.webSocketClient.send(data: request)
        } catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    public func send(candidate rtcIceCandidate: RTCIceCandidate, peerID: String, roomID: String) {
        let message = SignalingMessage.candidate(IceCandidate(from: rtcIceCandidate, peerID: peerID, roomID: roomID))
        do {
            let dataMessage = try self.encoder.encode(message)
            let dto = SignalingRequestDTO(messageType: .signaling, message: dataMessage)
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
        let message: SignalingMessage
        do {
            message = try self.decoder.decode(SignalingMessage.self, from: data)
        } catch {
            if let error = error as? DecodingError {
                debugPrint("수신한 메시지 decoding에 실패하였습니다.: \(error.fullDescription)")
                print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
            } else {
                debugPrint("수신한 메시지 decoding에 실패하였습니다.: \(error)")
                print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
            }
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalingService(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.delegate?.signalingService(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        @unknown default:
            debugPrint("Unknown Message Type: \(message)")
            return
        }
    }
}

public extension DecodingError {
    var fullDescription: String {
        switch self {
        case let .typeMismatch(type, context):
            return """
                    타입이 맞지 않습니다.\n
                    \(type) 타입에서 오류 발생:\n
                    codingPath: \(context.codingPath)\n
                    debugDescription: \(context.debugDescription)\n
                    underlyingError: \(context.underlyingError?.localizedDescription ?? "none")
                    """
        case let .valueNotFound(type, context):
            return """
                    값을 찾을 수 없습니다.\n
                    \(type) 타입에서 오류 발생:\n
                    codingPath: \(context.codingPath)\n
                    debugDescription: \(context.debugDescription)\n
                    underlyingError: \(context.underlyingError?.localizedDescription ?? "none")
                    """
        case let .keyNotFound(key, context):
            return """
                    키 \(key) 를 찾을 수 없습니다:\n
                    codingPath: \(context.codingPath)\n
                    debugDescription: \(context.debugDescription)\n
                    underlyingError: \(context.underlyingError?.localizedDescription ?? "none")
                    """
        case let .dataCorrupted(context):
            return """
                    데이터 손실 에러입니다.\n
                    codingPath: \(context.codingPath)\n
                    debugDescription: \(context.debugDescription)\n
                    underlyingError: \(context.underlyingError?.localizedDescription ?? "none")
                    """
        default:
            return "알 수 없는 디코딩에 실패했습니다."
        }
    }
}
