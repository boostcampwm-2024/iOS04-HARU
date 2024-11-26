import Foundation
import WebRTC
import Combine

public protocol ConnectionClient {
    var remoteVideoView: UIView { get }
    var remoteUserInfo: UserInfoEntity? { get }
    var receivedDataPublisher: PassthroughSubject<Data, Never> { get }
    
    func setRemoteUserInfo(_ remoteUserInfo: UserInfoEntity)
    func sendOffer()
    func sendData(data: Data)
    func captureVideo() -> UIImage
    func bindLocalVideo(_ localVideoView: UIView)
}
