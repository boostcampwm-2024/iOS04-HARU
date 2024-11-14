import DesignSystem
import EditPhotoRoomFeature
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
        
        // MARK: PhotoRoom -> EditPhotoRoom
        let images: [UIImage] = [
            PTGImage.temp1.image,
            PTGImage.temp2.image,
            PTGImage.temp3.image,
            PTGImage.temp4.image
        ]
        
        // MARK: EditPhotoRoom ~ ing
        let imageGenerator: FrameImageGenerator = FrameImageGeneratorImpl(images: images)
        imageGenerator.changeFrame(to: .defaultWhite)
        let image = imageGenerator.generate()
        
        // MARK: EditPhotoRoom -> SharePhotoRoom
        let imageData = image.pngData() ?? Data()
        let component = SharePhotoComponent(imageData: imageData)
        let sharePhotoViewModel = SharePhotoViewModel(component: component)
        let sharePhotoViewController = SharePhotoViewController(viewModel: sharePhotoViewModel)
        
        window?.rootViewController = sharePhotoViewController
        window?.makeKeyAndVisible()
    }
}
