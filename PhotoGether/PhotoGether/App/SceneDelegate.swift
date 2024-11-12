import UIKit
import PhotoGetherNetwork

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
        
        let webSocketClient = WebSocketClient(url: URL(string: baseURLString)!)
        let signalingClient = SignalingClient(webSocket: webSocketClient)
        
        signalingClient.connect()
        
        webSocketClient.send(data: Data("Hello, world!".utf8))
    }
}
