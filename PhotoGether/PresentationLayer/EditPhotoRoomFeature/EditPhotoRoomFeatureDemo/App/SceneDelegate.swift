import UIKit
import EditPhotoRoomFeature
import PhotoGetherDomainInterface
import PhotoGetherDomain
import PhotoGetherDomainTesting

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let imageNameList = [
            "blackHeart",
            "bug",
            "cat",
            "crown",
            "dog",
            "lips",
            "parkBug",
            "racoon",
            "redHeart",
            "star",
            "sunglasses",
            "tree",
        ]
        let shapeRepositoryMock = ShapeRepositoryMock(imageNameList: imageNameList)
        let fetchStickerListUseCase = FetchStickerListUseCaseImpl(shapeRepository: shapeRepositoryMock)
        let editPhotoRoomHostViewModel = EditPhotoRoomHostViewModel(fetchStickerListUseCase: fetchStickerListUseCase)
        let editPhotoRoomHostViewController = EditPhotoRoomHostViewController(viewModel: editPhotoRoomHostViewModel)
        window?.rootViewController = editPhotoRoomHostViewController
        window?.makeKeyAndVisible()
    }
}
