import UIKit
import Combine
import PhotoGetherDomainInterface

public final class ConnectionClientMock: ConnectionClient {
    public var remoteVideoView: UIView = UIView()
    
    public var localVideoView: UIView = UIView()
    
    public var receivedDataPublisher: PassthroughSubject<Data, Never> = PassthroughSubject()
    
    public func sendOffer() { }
    
    public func sendData(data: Data) { }
}
