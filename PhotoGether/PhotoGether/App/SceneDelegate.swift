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
        
        let webSocketClient: WebSocketClient = WebSocketClientImpl(url: url)
        
        let roomService: RoomService = RoomServiceImpl(
            webSocketClient: webSocketClient
        )
        
        let signalingService: SignalingService = SignalingServiceImpl(
            webSocketClient: webSocketClient
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
        
        let stopVideoCaptureUseCase: StopVideoCaptureUseCase = StopVideoCaptureUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let toggleLocalMicStateUseCaseImpl = ToggleLocalMicStateUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let getVoiceInputStateUseCaseImpl = GetVoiceInputStateUseCaseImpl(
            connectionRepository: connectionRepository
        )
        
        let photoRoomViewModel: PhotoRoomViewModel = PhotoRoomViewModel(
            captureVideosUseCase: captureVideosUseCase,
            stopVideoCaptureUseCase: stopVideoCaptureUseCase,
            getUserInfoUseCase: getLocalVideoUseCase,
            toggleLocalMicStateUseCase: toggleLocalMicStateUseCaseImpl,
            getVoiceInputStateUseCase: getVoiceInputStateUseCaseImpl
        )
        
        let localDataSource = LocalShapeDataSourceImpl()
        let remoteDataSource = RemoteShapeDataSourceImpl()
        let shapeRepositoryImpl = ShapeRepositoryImpl(
            localDataSource: localDataSource,
            remoteDataSource: remoteDataSource
        )
        let fetchEmojiListUseCase = FetchEmojiListUseCaseImpl(
            shapeRepository: shapeRepositoryImpl
        )
        
        let eventConnectionHostRepository = EventConnectionHostRepositoryImpl(
            clients: connectionRepository.clients
        )
        
        let eventConnectionGuestRepository = EventConnectionGuestRepositoryImpl(
            clients: connectionRepository.clients
        )
        
        let receiveStickerListHostUseCase = ReceiveStickerListUseCaseImpl(
            eventConnectionRepository: eventConnectionHostRepository
        )
        
        let sendStickerToRepositoryHostUseCase = SendStickerToRepositoryUseCaseImpl(
            eventConnectionRepository: eventConnectionHostRepository
        )
        
        let receiveStickerListGuestUseCase = ReceiveStickerListUseCaseImpl(
            eventConnectionRepository: eventConnectionGuestRepository
        )
        
        let sendStickerToRepositoryGuestUseCase = SendStickerToRepositoryUseCaseImpl(
            eventConnectionRepository: eventConnectionGuestRepository
        )

        let sendFrameToRepositoryGuestUseCase = SendFrameToRepositoryUseCaseImpl(
            eventConnectionRepository: eventConnectionGuestRepository
        )
        
        let sendFrameToRepositoryHostUseCase = SendFrameToRepositoryUseCaseImpl(
            eventConnectionRepository: eventConnectionHostRepository
        )
        
        let receiveFrameHostUseCase = ReceiveFrameUseCaseImpl(
            eventConnectionRepository: eventConnectionHostRepository
        )
        
        let receiveFrameGuestUseCase = ReceiveFrameUseCaseImpl(
            eventConnectionRepository: eventConnectionGuestRepository
        )
        
        let editPhotoRoomHostViewModel = EditPhotoRoomHostViewModel(
            receiveStickerListUseCase: receiveStickerListHostUseCase,
            receiveFrameUseCase: receiveFrameHostUseCase,
            sendStickerToRepositoryUseCase: sendStickerToRepositoryHostUseCase,
            sendFrameToRepositoryUseCase: sendFrameToRepositoryHostUseCase,
            toggleLocalMicStateUseCase: toggleLocalMicStateUseCaseImpl,
            getVoiceInputStateUseCase: getVoiceInputStateUseCaseImpl
        )
        
        let stickerBottomSheetViewModel = StickerBottomSheetViewModel(
            fetchEmojiListUseCase: fetchEmojiListUseCase
        )
        
        let stickerBottomSheetGuestViewController = StickerBottomSheetViewController(
            viewModel: stickerBottomSheetViewModel
        )
        
        let stickerBottomSheetHostViewController = StickerBottomSheetViewController(
            viewModel: stickerBottomSheetViewModel
        )
        
        let editPhotoRoomHostViewController = EditPhotoRoomHostViewController(
            viewModel: editPhotoRoomHostViewModel,
            bottomSheetViewController: stickerBottomSheetHostViewController
        )
        
        let editPhotoRoomGuestViewModel = EditPhotoRoomGuestViewModel(
            receiveStickerListUseCase: receiveStickerListGuestUseCase,
            receiveFrameUseCase: receiveFrameGuestUseCase,
            sendStickerToRepositoryUseCase: sendStickerToRepositoryGuestUseCase,
            sendFrameToRepositoryUseCase: sendFrameToRepositoryGuestUseCase,
            toggleLocalMicStateUseCase: toggleLocalMicStateUseCaseImpl,
            getVoiceInputStateUseCase: getVoiceInputStateUseCaseImpl
        )
        
        let editPhotoRoomGuestViewController = EditPhotoRoomGuestViewController(
            viewModel: editPhotoRoomGuestViewModel,
            bottomSheetViewController: stickerBottomSheetGuestViewController
        )
        
        let photoRoomViewController: PhotoRoomViewController = PhotoRoomViewController(
            editPhotoRoomHostViewController: editPhotoRoomHostViewController,
            editPhotoRoomGuestViewController: editPhotoRoomGuestViewController,
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
            didEnterNewUserPublisherUseCase: didEnterNewUserPublisherUseCase,
            toggleLocalMicStateUseCase: toggleLocalMicStateUseCaseImpl
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
