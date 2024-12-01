import Foundation
import WebRTC
import Combine

public protocol ConnectionClient {
    var remoteVideoView: UIView { get }
    var remoteUserInfo: UserInfo? { get }
    var receivedDataPublisher: PassthroughSubject<Data, Never> { get }
    
    func setRemoteUserInfo(_ remoteUserInfo: UserInfo)
    func sendOffer(myID: String)
    func sendData(data: Data)
    func captureVideo() -> UIImage
    func bindLocalVideo(_ localVideoView: UIView)
}
