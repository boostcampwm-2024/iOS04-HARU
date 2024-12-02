import UIKit
import Combine
import OSLog
import PhotoGetherDomainInterface
import CoreModule
import WebRTC

public final class ConnectionRepositoryImpl: ConnectionRepository {
    private var cancellables: Set<AnyCancellable> = []
    
    public var clients: [ConnectionClient]
    
    private let didEnterNewUserSubject = PassthroughSubject<(UserInfo, UIView), Never>()
    public var didEnterNewUserPublisher: AnyPublisher<(UserInfo, UIView), Never> {
        didEnterNewUserSubject.eraseToAnyPublisher()
    }
    private let didChangeLocalAudioTrackStateSubject = CurrentValueSubject<Bool, Never>(false)
    public var didChangeLocalAudioTrackStatePublisher: AnyPublisher<Bool, Never> {
        didChangeLocalAudioTrackStateSubject
            .eraseToAnyPublisher()
    }
    private let _localVideoView = CapturableVideoView()
    public private(set) var localUserInfo: UserInfo?
    
    public var localVideoView: UIView { _localVideoView }
    public var capturedLocalVideo: UIImage? { _localVideoView.capturedImage }
    
    private let roomService: RoomService
    private let signalingService: SignalingService
    
    private var videoCapturer: RTCVideoCapturer?
    private var videoSource: RTCVideoSource?
    
    public init(
        signlingService: SignalingService,
        roomService: RoomService,
        clients: [ConnectionClient]
    ) {
        self.signalingService = signlingService
        self.roomService = roomService
        self.clients = clients
        
        // MARK: local Video 캡쳐
        initVideoSource()
        initVideoCapturer()
        startCaptureLocalVideo()

        // MARK: Clients와 local Video, remote Video 연결
        bindLocalVideo()
        bindRemoteVideo()
        
        bindSignalingService()
        connectSignalingService()

        bindNotifyNewUserPublihser()
        bindLocalCandidatePublisher()
    }
    
    private func initVideoSource() {
        self.videoSource = PeerConnectionSupport.peerConnectionFactory.videoSource()
    }
    
    private func initVideoCapturer() {
        guard let videoSource else { return }
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
    }
    
    private func startCaptureLocalVideo() {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else { return }
        guard let frontCamera = RTCCameraVideoCapturer.captureDevices().first(where: {
            $0.position == .front
        }) else { return }
                      
        // 가장 낮은 해상도 선택
        guard let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera)
            .sorted { frame1, frame2 -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(frame1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(frame2.formatDescription).width
                return width1 < width2
            }).first else { return }
        // 가장 높은 fps 선택
        guard let fps = (format.videoSupportedFrameRateRanges
            .sorted { return $0.maxFrameRate < $1.maxFrameRate })
            .last else { return }

        capturer.startCapture(
            with: frontCamera,
            format: format,
            fps: Int(fps.maxFrameRate)
        )
    }
    
    public func stopCaptureLocalVideo() -> Bool {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else { return false }
        capturer.stopCapture()
        return true
    }
    
    private func bindLocalVideo() {
        self.clients.forEach { $0.bindLocalVideo(videoSource: self.videoSource, _localVideoView) }
    }
    
    private func bindRemoteVideo() {
        self.clients.forEach { $0.bindRemoteVideo() }
    }

    public func createRoom() -> AnyPublisher<RoomOwnerEntity, Error> {
        return roomService.createRoom().map { [weak self] entity -> RoomOwnerEntity in
            guard let self else { return entity }
            return self.setLocalUserInfo(entity: entity)
        }
        .eraseToAnyPublisher()
    }
    
    public func joinRoom(to roomID: String, hostID: String) -> AnyPublisher<Bool, Error> {
        return roomService.joinRoom(to: roomID).map { [weak self] entity -> Bool in
            guard let self else { return false }
            guard entity.userList.count <= clients.count + 1 else { return false }
            let setLocalUserInfoResult = setLocalUserInfo(entity: entity)
            let setRemoteUserInfoResult = setRemoteUserInfo(entity: entity, hostID: hostID)
            
            return setLocalUserInfoResult && setRemoteUserInfoResult
        }
        .eraseToAnyPublisher()
    }
    
    public func sendOffer() async throws {
        guard let myID = localUserInfo?.id else {
            PTGLogger.default.log("sendOffer: localUserInfo 가 nil 입니다.")
            throw NSError()
        }
        guard let roomID = localUserInfo?.roomID else { throw NSError() }
        
        for client in self.clients where client.remoteUserInfo != nil {
            guard let sdp = try? await client.createOffer() else {
                PTGLogger.default.log("offer 생성 중 에러가 발생했습니다.")
                throw NSError()
            }
            
            guard let remoteUserInfo = client.remoteUserInfo else { return }
            
            self.signalingService.send(
                type: .offerSDP,
                sdp: sdp,
                roomID: roomID,
                offerID: myID,
                answerID: remoteUserInfo.id
            )
        }
    }
    
    public func switchLocalAudioTrackState() {
        let presentAudioState = didChangeLocalAudioTrackStateSubject.value
        clients.forEach {
            $0.toggleLocalAudioTrackState(isEnable: !presentAudioState)
        }
        didChangeLocalAudioTrackStateSubject.send(!presentAudioState)
    }
}

extension ConnectionRepositoryImpl {
    private func connectSignalingService() {
        self.signalingService.connect()
    }
    
    private func bindSignalingService() {
        // MARK: 이미 방에 있던 놈들이 받는 이벤트
        self.signalingService.didReceiveOfferSdpPublisher
            .sink { [weak self] sdpMessage in
                guard let self else { return }
                PTGLogger.default.log("didReceiveRemoteSdpPublisher sink!! \(sdpMessage.offerID)")

                guard let localUserInfo = self.localUserInfo else {
                    PTGLogger.default.log("localUserInfo가 없어요!! 비상!!!")
                    return
                }

                Task {
                    do {
                        let remoteSDP = sdpMessage.rtcSessionDescription
                        guard let offerSender = self.clients.first(where: { $0.remoteUserInfo?.id == sdpMessage.offerID }) else {
                            PTGLogger.default.log("해당 offerID에 해당하는 유저를 찾을 수 없습니다.")
                            return
                        }
                        
                        try await offerSender.set(remoteSdp: remoteSDP)
                        guard let answerSDP = try? await offerSender.createAnswer() else {
                            PTGLogger.default.log("Answer SDP를 생성할 수 없습니다.")
                            return
                        }
                        
                        self.signalingService.send(
                            type: .answerSDP,
                            sdp: answerSDP,
                            roomID: localUserInfo.roomID,
                            offerID: sdpMessage.offerID,
                            answerID: sdpMessage.answerID
                        )
                    } catch {
                        PTGLogger.default.log("Offer SDP 수신 중 에러: \(error.localizedDescription)")
                    }
                }
            }
            .store(in: &cancellables)
        
        self.signalingService.didReceiveAnswerSdpPublisher
            .sink { [weak self] sdpMessage in
                guard let self else { return }
                let remoteSDP = sdpMessage.rtcSessionDescription
                
                guard let answerReceiver = self.clients.first(where: { $0.remoteUserInfo?.id == sdpMessage.answerID }) else {
                    PTGLogger.default.log("answerReceiver가 없어요! \(String(describing: sdpMessage.answerID))")
                    return
                }
                
                Task {
                    do {
                        try await answerReceiver.set(remoteSdp: remoteSDP)
                    } catch {
                        PTGLogger.default.log("Answer SDP 저장 중 에러: \(error.localizedDescription)")
                    }
                }
            }.store(in: &cancellables)
        
        self.signalingService.didReceiveCandidatePublisher.sink { [weak self] candidate in
            guard let self else { return }

            guard let candidateReceiver = self.clients.first(where: { $0.remoteUserInfo?.id == candidate.senderID }) else {
                PTGLogger.default.log("candidateReceiver가 없어요! \(candidate.senderID)")
                return
            }
            Task {
                do {
                    try await candidateReceiver.set(remoteCandidate: candidate.rtcIceCandidate)
                } catch {
                    PTGLogger.default.log("Candidate 저장 중 에러: \(error.localizedDescription) \(candidate.sdp)")
                }
            }
            
        }.store(in: &cancellables)
    }
    
    private func bindNotifyNewUserPublihser() {
        roomService.notifyRoomResponsePublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    PTGLogger.default.log(error.localizedDescription)
                }
            }, receiveValue: {  [weak self] entity in
                guard let self else { return }
                let newUser = entity.newUser
                guard let emptyClient = clients.first(where: { $0.remoteUserInfo == nil }) else {
                    PTGLogger.default.log("방이 가득 찼는데 누군가 입장했어요!")
                    return
                }
                
                guard let viewPosition = UserInfo.ViewPosition(rawValue: newUser.initialPosition),
                      let roomID = self.localUserInfo?.roomID
                else { return }
                
                let newUserInfoEntity = UserInfo(
                    id: newUser.userID,
                    nickname: newUser.nickname,
                    isHost: false,
                    viewPosition: viewPosition,
                    roomID: roomID
                )
                                
                emptyClient.setRemoteUserInfo(newUserInfoEntity)
                didEnterNewUserSubject.send((newUserInfoEntity, emptyClient.remoteVideoView))
                PTGLogger.default.log("newUser Entered: \(newUserInfoEntity)")
            })
            .store(in: &cancellables)
    }
    
    private func bindLocalCandidatePublisher() {
        clients.forEach {
            $0.didGenerateLocalCandidatePublisher.sink { [weak self] receiverID, candidate in
                guard let self else { return }
                PTGLogger.default.log("didGenerateLocalCandidatePublisher: \(receiverID)")
                guard let localUserInfo = self.localUserInfo else {
                    PTGLogger.default.log("localUserInfo가 없어요!! 비상!!!")
                    return
                }
                self.signalingService.send(
                    type: .iceCandidate,
                    candidate: candidate,
                    roomID: localUserInfo.roomID,
                    receiverID: receiverID,
                    senderID: localUserInfo.id
                )
            }.store(in: &cancellables)
        }
    }
    
    private func setLocalUserInfo(entity: JoinRoomEntity) -> Bool {
        guard let localUserInfo = localUserInfo(for: entity) else { return false }
        self.localUserInfo = localUserInfo
        return true
    }
    
    private func setLocalUserInfo(entity: RoomOwnerEntity) -> RoomOwnerEntity {
        guard let localUserInfo = localUserInfo(for: entity) else { return entity }
        self.localUserInfo = localUserInfo
        self.didEnterNewUserSubject.send((localUserInfo, localVideoView))
        return entity
    }
    
    private func setRemoteUserInfo(entity: JoinRoomEntity, hostID: String) -> Bool {
        let remoteUserInfoList = remoteUserInfoList(for: entity, hostID: hostID)
        
        for (idx, userInfo) in remoteUserInfoList.enumerated() {
            clients[idx].setRemoteUserInfo(userInfo)
        }
        return true
    }
    
    private func localUserInfo(for entity: JoinRoomEntity) -> UserInfo? {
        let myID = entity.userID
        let clientsInfo = entity.userList
        guard let myInfo = clientsInfo.first(where: { $0.userID == myID }),
              let viewPosition = UserInfo.ViewPosition(rawValue: myInfo.initialPosition)
        else { return nil }
        
        return UserInfo(
            id: myInfo.userID,
            nickname: myInfo.nickname,
            isHost: false,
            viewPosition: viewPosition,
            roomID: entity.roomID
        )
    }
    
    private func localUserInfo(for entity: RoomOwnerEntity) -> UserInfo? {
        return UserInfo(
            id: entity.hostID,
            nickname: String(entity.hostID.suffix(4)), // TODO: 서버에서 받아온 닉네임으로 변경 예정
            isHost: true,
            viewPosition: .topLeading,
            roomID: entity.roomID
        )
    }
    
    private func remoteUserInfoList(for entity: JoinRoomEntity, hostID: String) -> [UserInfo] {
        var result: [UserInfo] = []
        let clientsInfo = entity.userList.filter { $0.userID != entity.userID }
        result = clientsInfo.map {
            let userID = $0.userID
            guard let userInfo = clientsInfo.first(where: { $0.userID == userID }),
                  let viewPosition = UserInfo.ViewPosition(rawValue: userInfo.initialPosition),
                  let roomID = self.localUserInfo?.roomID
            else { return nil }
            let isHost = userID == hostID
            
            return UserInfo(
                id: userInfo.userID,
                nickname: userInfo.nickname,
                isHost: isHost,
                viewPosition: viewPosition,
                roomID: roomID
            )
        }.compactMap { $0 }

        return result
    }
}
