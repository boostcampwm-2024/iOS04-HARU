import PhotoGetherNetwork
import PhotoGetherDomain
import PhotoGetherDomainInterface
import WaitingRoomFeature
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        let url = URL(string: urlString)!
        debugPrint("SignalingServer URL: \(url)")
        let webScoketClient: WebSocketClient = WebSocketClientImpl(url: url)
        let signalingClient: SignalingClient = SignalingClientImpl(webSocketClient: webScoketClient)
        let webRTCClient: WebRTCClient = WebRTCClientImpl(iceServers: [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
            "stun:stun2.l.google.com:19302",
            "stun:stun3.l.google.com:19302",
            "stun:stun4.l.google.com:19302"
        ])
        let connectionClient: ConnectionClient = ConnectionClientImpl(signalingClient: signalingClient, webRTCClient: webRTCClient)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = WaitingRoomViewController(connectionClient: connectionClient)
        window?.makeKeyAndVisible()
    }
}
