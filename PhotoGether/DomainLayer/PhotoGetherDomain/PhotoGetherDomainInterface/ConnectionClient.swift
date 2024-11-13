import Foundation
import WebRTC

public protocol ConnectionClient: SignalingClientDelegate, WebRTCClientDelegate {
    var remoteVideoView: UIView { get }
    
    func connect()
    func sendData(data: Data)
}
