import UIKit
import BaseFeature
import Combine
import DesignSystem
import EditPhotoRoomFeature
import PhotoGetherDomain
import PhotoGetherData
import PhotoGetherDomainInterface

public final class PhotoRoomViewController: BaseViewController, ViewControllerConfigure {
    private let navigationView = UIView()
    var participantsViewController: ParticipantsCollectionViewController!
    var connectionRepsitory: ConnectionRepository
    private let photoRoomBottomView: PhotoRoomBottomView
    private var isHost: Bool
    
    private let input = PassthroughSubject<PhotoRoomViewModel.Input, Never>()
    
    private let viewModel: PhotoRoomViewModel
    
    public init(
        connectionRepsitory: ConnectionRepository,
        viewModel: PhotoRoomViewModel,
        isHost: Bool
    ) {
        self.connectionRepsitory = connectionRepsitory
        self.viewModel = viewModel
        self.isHost = isHost
        self.photoRoomBottomView = PhotoRoomBottomView(isHost: isHost)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        addViews()
        setupConstraints()
        configureUI()
        bindInput()
        bindOutput()
        bindNoti()
    }
    
    public func setCollectionViewController(_ viewController: ParticipantsCollectionViewController) {
        self.participantsViewController = viewController
    }
    
    private func bindNoti() {
        NotificationCenter.default.publisher(for: .startCountDown).sink { [weak self] noti in
            self?.isHost = false
            self?.input.send(.cameraButtonTapped)
        }.store(in: &cancellables)
    }
    
    public func addViews() {
        self.addChild(participantsViewController)
        participantsViewController.didMove(toParent: self)
        
        [navigationView, participantsViewController.view, photoRoomBottomView].forEach {
            view.addSubview($0)
        }
    }
    
    public func setupConstraints() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(Constants.navigationHeight)
        }
        
        participantsViewController.view.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(photoRoomBottomView.snp.top)
        }
        
        photoRoomBottomView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(Constants.bottomViewHeight)
        }
    }
    
    public func configureUI() {
        navigationView.backgroundColor = PTGColor.gray90.color
    }
    
    public func bindInput() {
        photoRoomBottomView.cameraButtonTapped
            .filter { [weak self] in
                return self?.isHost ?? false
            }
            .sink { _ in
                NotificationCenter.default.post(name: .startCountDown, object: nil)
            }
            .store(in: &cancellables)
    }
    
    public func bindOutput() {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        
        output.sink { [weak self] in
            guard let self else { return }
            switch $0 {
            case .timer(let count):
                self.photoRoomBottomView.setCameraButtonTimer(count)
            case .timerCompleted(let images):
                self.photoRoomBottomView.stopCameraButtonTimer()
                
//                let localDataSource = LocalShapeDataSourceImpl()
//                let remoteDataSource = RemoteShapeDataSourceImpl()
//                let repository = ShapeRepositoryImpl(
//                    localDataSource: localDataSource,
//                    remoteDataSource: remoteDataSource
//                )
//                let eventConnectionRepository = EventConnectionHostRepositoryImpl(
//                    clients: self.connectionRepsitory.clients
//                )
//                
//                let fetchEmojiListUseCase = FetchEmojiListUseCaseImpl(
//                    shapeRepository: repository
//                )
//                let frameImageGenerator = FrameImageGeneratorImpl(
//                    images: images
//                )
//                let sendStickerToRepositoryUseCase = SendStickerToRepositoryUseCaseImpl(
//                    eventConnectionRepository: eventConnectionRepository
//                )
//                let receiveStickerListUseCase = ReceiveStickerListUseCaseImpl(
//                    eventConnectionRepository: eventConnectionRepository
//                )
//                
//                let frameUseCaseImpl = ReceiveFrameUseCaseImpl(eventConnectionRepository: eventConnectionRepository)
//                let sendStickerToRepoUCIMPL = SendStickerToRepositoryUseCaseImpl(eventConnectionRepository: eventConnectionRepository)
//                let sftrucimpl = SendFrameToRepositoryUseCaseImpl(eventConnectionRepository: eventConnectionRepository)
//                let viewModel = EditPhotoRoomHostViewModel(
//                    frameImageGenerator: frameImageGenerator,
//                    receiveStickerListUseCase: receiveStickerListUseCase,
//                    receiveFrameUseCase: frameUseCaseImpl,
//                    sendStickerToRepositoryUseCase: sendStickerToRepositoryUseCase,
//                    sendFrameToRepositoryUseCase: sftrucimpl
//                )
//                let btvm = StickerBottomSheetViewModel(fetchEmojiListUseCase: fetchEmojiListUseCase)
//                
//                let btvc = StickerBottomSheetViewController(viewModel: btvm)
//                let vc = EditPhotoRoomHostViewController(viewModel: viewModel, bottomSheetViewController: btvc)
//                
//                let vcvc = EditPhotoRoomGuestViewModel(
//                    frameImageGenerator: frameImageGenerator,
//                    receiveStickerListUseCase: <#T##any ReceiveStickerListUseCase#>,
//                    receiveFrameUseCase: <#T##any ReceiveFrameUseCase#>,
//                    sendStickerToRepositoryUseCase: <#T##any SendStickerToRepositoryUseCase#>,
//                    sendFrameToRepositoryUseCase: <#T##any SendFrameToRepositoryUseCase#>
//                )
//                
//                let uhmmVC = OfferTempViewController2(
//                    hostViewController: vc,
//                    guestViewController: <#T##EditPhotoRoomGuestViewController#>
//                )
//
                
                let roomService = connectionRepsitory.roomService
                let clients = connectionRepsitory.clients
                let repository = ConnectionRepositoryImpl(clients: clients, roomService: roomService)
                let offerUseCase = SendOfferUseCaseImpl(repository: repository)
                let localDataSource = LocalShapeDataSourceImpl()
                let remoteDataSource = RemoteShapeDataSourceImpl()
                let shapeRepositoryImpl = ShapeRepositoryImpl(
                    localDataSource: localDataSource,
                    remoteDataSource: remoteDataSource
                )
                let fetchEmojiListUseCase = FetchEmojiListUseCaseImpl(
                    shapeRepository: shapeRepositoryImpl
                )
                let images = [
                    PTGImage.temp1.image,
                    PTGImage.temp2.image,
                    PTGImage.temp3.image,
                    PTGImage.temp4.image,
                ]
                let frameImageGenerator = FrameImageGeneratorImpl(images: images)
                
                let eventConnectionHostRepository = EventConnectionHostRepositoryImpl(clients: clients)
                
                let eventConnectionGuestRepository = EventConnectionGuestRepositoryImpl(clients: clients)
                
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
                    frameImageGenerator: frameImageGenerator,
                    receiveStickerListUseCase: receiveStickerListHostUseCase,
                    receiveFrameUseCase: receiveFrameHostUseCase,
                    sendStickerToRepositoryUseCase: sendStickerToRepositoryHostUseCase,
                    sendFrameToRepositoryUseCase: sendFrameToRepositoryHostUseCase
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
                    frameImageGenerator: frameImageGenerator,
                    receiveStickerListUseCase: receiveStickerListGuestUseCase,
                    receiveFrameUseCase: receiveFrameGuestUseCase,
                    sendStickerToRepositoryUseCase: sendStickerToRepositoryGuestUseCase,
                    sendFrameToRepositoryUseCase: sendFrameToRepositoryGuestUseCase
                )
                
                let editPhotoRoomGuestViewController = EditPhotoRoomGuestViewController(
                    viewModel: editPhotoRoomGuestViewModel,
                    bottomSheetViewController: stickerBottomSheetGuestViewController
                )
                if isHost {
                    self.navigationController?.pushViewController(editPhotoRoomHostViewController, animated: true)
                } else {
                    self.navigationController?.pushViewController(editPhotoRoomGuestViewController, animated: true)
                }
            }
        }
        .store(in: &cancellables)
    }
}

extension PhotoRoomViewController {
    private enum Constants {
        static let bottomViewHeight: CGFloat = 80
        static let navigationHeight: CGFloat = 48
    }
}
