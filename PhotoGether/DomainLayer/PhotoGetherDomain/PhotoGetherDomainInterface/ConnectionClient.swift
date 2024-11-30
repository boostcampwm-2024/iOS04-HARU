import Foundation
import WebRTC
import Combine

public protocol ConnectionClient {
    var remoteVideoView: UIView { get }
    var remoteUserInfo: UserInfo? { get }
    
    var receivedDataPublisher: AnyPublisher<Data, Never> { get }
    var didGenerateLocalCandidatePublisher: AnyPublisher<(receiverID: String, RTCIceCandidate), Never> { get }
    
    func createOffer() async throws -> RTCSessionDescription
    func createAnswer() async throws -> RTCSessionDescription

    func set(remoteSdp: RTCSessionDescription) async throws
    func set(localSdp: RTCSessionDescription) async throws
    func set(remoteCandidate: RTCIceCandidate) async throws
    
    func setRemoteUserInfo(_ remoteUserInfo: UserInfo)
    func sendData(data: Data)
    func captureVideo() -> UIImage
    func bindLocalVideo(_ localVideoView: UIView)
}
