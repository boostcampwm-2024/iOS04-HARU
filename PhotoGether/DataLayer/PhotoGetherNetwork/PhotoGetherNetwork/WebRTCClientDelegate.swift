import Foundation
import WebRTC

public protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didGenerateLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}
