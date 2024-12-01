import DesignSystem
import PhotoGetherDomainInterface
import SharePhotoFeature
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let image = PTGImage.sampleImage.image
        
        // MARK: EditPhotoRoom -> SharePhotoRoom
        let imageData = image.pngData() ?? Data()
        let component = SharePhotoComponent(imageData: imageData)
        let sharePhotoViewModel = SharePhotoViewModel(component: component)
        let sharePhotoViewController = SharePhotoViewController(viewModel: sharePhotoViewModel)
        
        window?.rootViewController = sharePhotoViewController
        window?.makeKeyAndVisible()
    }
}
