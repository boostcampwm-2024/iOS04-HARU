import Foundation
import WebRTC

public protocol ConnectionClient: SignalingClientDelegate, WebRTCClientDelegate {
    var remoteVideoView: UIView { get }
    
    func sendOffer(offer: RTCSessionDescription)
    func sendData(data: Data)
}
