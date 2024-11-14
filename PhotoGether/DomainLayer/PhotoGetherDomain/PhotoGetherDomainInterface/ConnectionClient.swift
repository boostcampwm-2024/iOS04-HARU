import Foundation
import WebRTC
import Combine

public protocol ConnectionClient: SignalingClientDelegate, WebRTCClientDelegate {
    var dataReceivedSubject: PassthroughSubject<Data, Never> { get }

    var remoteVideoView: UIView { get }
    var localVideoView: UIView { get }
    
    func sendOffer()
    func sendData(data: Data)
    func captureVideo() -> [UIImage]
}
