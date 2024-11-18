import Foundation
import WebRTC
import Combine

public protocol ConnectionClient: SignalingClientDelegate, WebRTCClientDelegate {
    var remoteVideoView: UIView { get }
    var localVideoView: UIView { get }
    
    var receivedDataPublisher: PassthroughSubject<Data, Never> { get }
    
    func sendOffer()
    func sendData(data: Data)
}
