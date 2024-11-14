import Foundation
import WebRTC

public protocol ConnectionClient: SignalingClientDelegate, WebRTCClientDelegate {
    var remoteVideoView: UIView { get }
    var localVideoView: UIView { get }
    
    func sendOffer()
    func sendData(data: Data)
}
