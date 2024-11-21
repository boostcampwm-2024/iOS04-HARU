import UIKit
import EditPhotoRoomFeature
import PhotoGetherData
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
        
        // TODO: 추후 Data 의존성 제거 및 Mock으로 전환
//        let shapeRepositoryMock = ShapeRepositoryMock(imageNameList: imageNameList)
        let localDataSource = LocalShapeDataSourceImpl()
        let remoteDataSource = RemoteShapeDataSourceImpl()
        let shapeRepositoryImpl = ShapeRepositoryImpl(localDataSource: localDataSource, remoteDataSource: remoteDataSource)
        let fetchStickerListUseCase = FetchStickerListUseCaseImpl(shapeRepository: shapeRepositoryImpl)
        let editPhotoRoomHostViewModel = EditPhotoRoomHostViewModel(fetchStickerListUseCase: fetchStickerListUseCase)
        let editPhotoRoomHostViewController = EditPhotoRoomHostViewController(viewModel: editPhotoRoomHostViewModel)
        window?.rootViewController = editPhotoRoomHostViewController
        window?.makeKeyAndVisible()
    }
}
