import Foundation
import WebRTC

final public class SignalingClient {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketClient
    public weak var delegate: SignalClientDelegate?
    
    public init(webSocket: WebSocketClient) {
        self.webSocket = webSocket
    }
    
    public func connect() {
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    public func send(sdp rtcSdp: RTCSessionDescription) {
        let message = SignalingMessage.sdp(SessionDescription(from: rtcSdp))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        } catch {
            debugPrint("Warning: Could not encode sdp: \(error)")
        }
    }
    
    public func send(candidate rtcIceCandidate: RTCIceCandidate) {
        let message = SignalingMessage.candidate(IceCandidate(from: rtcIceCandidate))
        do {
            let dataMessage = try self.encoder.encode(message)
            self.webSocket.send(data: dataMessage)
        } catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
    }
}

extension SignalingClient: WebSocketClientDelegate {
    public func webSocketDidConnect(_ webSocket: WebSocketClient) {
        self.delegate?.signalClientDidConnect(self)
    }
    
    public func webSocketDidDisconnect(_ webSocket: WebSocketClient) {
        self.delegate?.signalClientDidDisconnect(self)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            debugPrint("Trying to reconnect to signaling server...")
            self.webSocket.connect()
        }
    }
    
    public func webSocket(_ webSocket: WebSocketClient, didReceiveData data: Data) {
        let message: SignalingMessage
        do {
            message = try self.decoder.decode(SignalingMessage.self, from: data)
        } catch {
            debugPrint("Warning: Could not decode incoming message: \(error)")
            return
        }
        
        switch message {
        case .candidate(let iceCandidate):
            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
        case .sdp(let sessionDescription):
            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
        }
    }
}
