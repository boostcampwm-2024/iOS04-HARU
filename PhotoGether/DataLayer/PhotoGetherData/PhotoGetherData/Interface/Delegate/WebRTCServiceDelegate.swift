import Foundation
import WebRTC

public protocol WebRTCServiceDelegate: AnyObject {
    func webRTCService(_ service: WebRTCService, didGenerateLocalCandidate candidate: RTCIceCandidate)
    func webRTCService(_ service: WebRTCService, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCService(_ service: WebRTCService, didReceiveData data: Data)
}
