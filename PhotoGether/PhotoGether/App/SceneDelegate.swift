import UIKit
import PhotoGetherNetwork
import PhotoGetherData
import PhotoGetherDomainInterface
import PhotoGetherDomain
import WaitingRoomFeature
import PhotoRoomFeature
import EditPhotoRoomFeature
import SharePhotoFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    // swiftlint:disable function_body_length
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        guard let url = Secrets.BASE_URL else { return }
        guard let stunServers = Secrets.STUN_SERVERS else { return }
        debugPrint("SignalingServer URL: \(url)")
        
        var isHost: Bool = true
        var roomOwnerEntity: RoomOwnerEntity?
        
        if let urlContext = connectionOptions.urlContexts.first {
            // MARK: 딥링크로 들어온지 여부로 호스트 게스트 판단
            isHost = false
            roomOwnerEntity = DeepLinkParser.parseRoomInfo(from: urlContext.url)
        }
        
        let webScoketClient: WebSocketClient = WebSocketClientImpl(url: url)
        
        let roomService: RoomService = RoomServiceImpl(
            webSocketClient: webScoketClient
        )
        
        let signalingService: SignalingService = SignalingServiceImpl(
            webSocketClient: webScoketClient
        )
        
        let connectionRepository: ConnectionRepository = ConnectionRepositoryImpl(
            signlingService: signalingService,
            roomService: roomService,
            clients: [
                makeConnectionClient(
                    webRTCService: makeWebRTCService(
                        iceServers: stunServers
                    )
                ),
                makeConnectionClient(
                    webRTCService: makeWebRTCService(
                        iceServers: stunServers
                    )
                ),
                makeConnectionClient(
                    webRTCService: makeWebRTCService(
                        iceServers: stunServers
                    )
                )
            ]
        )
        
        let sendOfferUseCase: SendOfferUseCase = SendOfferUseCaseImpl(
            repository: connectionRepository
        )
        
        let getLocalVideoUseCase: GetLocalVideoUseCase = GetLocalVideoUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let getRemoteVideoUseCase: GetRemoteVideoUseCase = GetRemoteVideoUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let captureVideosUseCase: CaptureVideosUseCase = CaptureVideosUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let createRoomUseCase: CreateRoomUseCase = CreateRoomUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let didEnterNewUserPublisherUseCase: DidEnterNewUserPublisherUseCase = DidEnterNewUserPublisherUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let photoRoomViewModel: PhotoRoomViewModel = PhotoRoomViewModel(
            captureVideosUseCase: captureVideosUseCase
        )
        
        let photoRoomViewController: PhotoRoomViewController = PhotoRoomViewController(
            connectionRepsitory: connectionRepository,
            viewModel: photoRoomViewModel,
            isHost: isHost
        )
        
        let waitingRoomViewModel: WaitingRoomViewModel = WaitingRoomViewModel(
            isHost: isHost,
            sendOfferUseCase: sendOfferUseCase,
            getLocalVideoUseCase: getLocalVideoUseCase,
            getRemoteVideoUseCase: getRemoteVideoUseCase,
            createRoomUseCase: createRoomUseCase,
            didEnterNewUserPublisherUseCase: didEnterNewUserPublisherUseCase
        )
        
        let waitingRoomViewController: WaitingRoomViewController = WaitingRoomViewController(
            viewModel: waitingRoomViewModel,
            photoRoomViewController: photoRoomViewController
        )
        
        window = UIWindow(windowScene: windowScene)
        
        if !isHost {
            let joinRoomUseCase: JoinRoomUseCase = JoinRoomUseCaseImpl(
                connectionRepository: connectionRepository
            )
            
            guard let roomOwnerEntity else { return }
            
            let enterLoadingViewModel = EnterLoadingViewModel(
                joinRoomUseCase: joinRoomUseCase,
                roomID: roomOwnerEntity.roomID,
                hostID: roomOwnerEntity.hostID
            )
            let enterLoadingViewController = EnterLoadingViewController(
                viewModel: enterLoadingViewModel,
                waitingRoomViewController: waitingRoomViewController
            )
            
            window?.rootViewController = UINavigationController(rootViewController: enterLoadingViewController)
        } else {
            window?.rootViewController = UINavigationController(rootViewController: waitingRoomViewController)
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func makeWebRTCService(
        iceServers: [String]
    ) -> WebRTCService {
        return WebRTCServiceImpl(
            iceServers: iceServers
        )
    }
    
    private func makeConnectionClient(
        webRTCService: WebRTCService
    ) -> ConnectionClient {
        return ConnectionClientImpl(
            webRTCService: webRTCService
        )
    }
}
