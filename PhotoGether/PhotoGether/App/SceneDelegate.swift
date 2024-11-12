import UIKit
import PhotoGetherNetwork
import PhotoGetherDomain
import PhotoGetherDomainInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        
        let webSocketClient: WebSocketClient = WebSocketClientImpl(url: URL(string: baseURLString)!)
        let signalingClient: SignalingClient = SignalingClientImpl(webSocketClient: webSocketClient)
        
        signalingClient.connect()
    }
}
