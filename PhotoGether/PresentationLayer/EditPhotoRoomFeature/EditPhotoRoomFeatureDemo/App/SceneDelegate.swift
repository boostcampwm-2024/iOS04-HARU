import UIKit
import EditPhotoRoomFeature
import DesignSystem

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let images = [
            PTGImage.temp1.image,
            PTGImage.temp2.image,
            PTGImage.temp3.image,
            PTGImage.temp4.image,
        ]
        let frameImageGenerator = FrameImageGeneratorImpl(images: images)
        let viewModel = EditPhotoRoomHostViewModel(frameImageGenerator: frameImageGenerator)
        let viewController = EditPhotoRoomHostViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
