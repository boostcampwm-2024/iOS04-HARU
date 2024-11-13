import Foundation
import WebRTC
import PhotoGetherDomainInterface

final public class SignalingClientImpl: SignalingClient {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var webSocketClient: WebSocketClient
    public weak var delegate: SignalingClientDelegate?
    
    public init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
        self.webSocketClient.delegate = self
    }
    
    public func connect() {
        self.webSocketClient.connect()
    }
    
    public func send(sdp rtcSdp: RTCSessionDescription) {
        let message = SignalingMessage.sdp(SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocketClient.send(data: dataMessage)
        } catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    public func send(candidate rtcIceCandidate: RTCIceCandidate) {
        let message = SignalingMessage.candidate(IceCandidate(from: rtcIceCandidate))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocketClient.send(data: dataMessage)
        } catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}

// MARK: WebSocketClientDelegate
extension SignalingClientImpl {
    public func webSocketDidConnect(_ webSocket: WebSocketClient) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    public func webSocketDidDisconnect(_ webSocket: WebSocketClient) {
        self.delegate?.signalClientDidDisconnect(self)
        
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
            debugPrint("수신한 메시지 decoding에 실패하였습니다.: \(error)")
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        @unknown default:
            debugPrint("Unknown Message Type: \(message)")
            return
        }
    }
}
