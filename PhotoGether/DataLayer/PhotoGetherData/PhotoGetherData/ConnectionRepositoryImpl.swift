import UIKit
import Combine
import OSLog
import PhotoGetherDomainInterface

public final class ConnectionRepositoryImpl: ConnectionRepository {
    private var cancellables: Set<AnyCancellable> = []
    
    public var clients: [ConnectionClient]
    
    private let _localVideoView = CapturableVideoView()
    private var localUserInfo: UserInfo?
    
    public var localVideoView: UIView { _localVideoView }
    public var capturedLocalVideo: UIImage? { _localVideoView.capturedImage }
    
    private let roomService: RoomService
    private let signalingService: SignalingService
    
    public init(
        clients: [ConnectionClient],
        roomService: RoomService,
        signlingService: SignalingService
    ) {
        self.clients = clients
        self.roomService = roomService
        self.signalingService = signlingService
        connectSignalingService()
        bindLocalVideo()
        bindNotifyNewUserPublihser()
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
            guard entity.userList.count <= clients.count else { return false }
            let setLocalUserInfoResult = setLocalUserInfo(entity: entity)
            let setRemoteUserInfoResult = setRemoteUserInfo(entity: entity, hostID: hostID)
            
            return setLocalUserInfoResult && setRemoteUserInfoResult
        }
        .eraseToAnyPublisher()
    }
    
    public func sendOffer() async -> Bool {
        guard let myID = localUserInfo?.id else { return false }
        guard let roomID = localUserInfo?.roomID else { return false }
        
        for client in self.clients {
            do {
                let sdp = try await client.createOffer()
                self.signalingService.send(
                    type: .offerSDP,
                    sdp: sdp,
                    roomID: roomID,
                    offerID: myID,
                    answerID: nil
                )
            } catch {
                PTGDataLogger.log("offer 생성 중 에러가 발생했습니다. \(error.localizedDescription)")
                return false
            }
        }
        
        return true
    }
}

extension ConnectionRepositoryImpl {
    private func connectSignalingService() {
        self.signalingService.connect()
    }
    
    private func bindSignalingService() {
        // MARK: 이미 방에 있던 놈들이 받는 이벤트
        self.signalingService.didReceiveOfferSdpPublisher
            .filter { [weak self] _ in self?.remoteUserInfo != nil }
            .sink { [weak self] sdpMessage in
                guard let self else { return }
                let remoteSDP = sdpMessage.rtcSessionDescription
                
                PTGDataLogger.log("didReceiveRemoteSdpPublisher sink!! \(remoteSDP)")
                
                // MARK: remoteDescription이 있으면 이미 연결된 클라이언트
                guard self.webRTCService.peerConnection.remoteDescription == nil else {
                    PTGDataLogger.log("remoteSDP가 이미 있어요!")
                    return
                }
                PTGDataLogger.log("remoteSDP가 없어요! remoteSDP 저장하기 직전")
                guard let userInfo = self.remoteUserInfo else {
                    PTGDataLogger.log("answer를 받을 remote User가 없어요!! 비상!!!")
                    return
                }
                
                guard userInfo.id == sdpMessage.offerID else {
                    PTGDataLogger.log("Offer를 보낸 유저가 일치하지 않습니다.")
                    return
                }
                
                guard self.webRTCService.peerConnection.localDescription == nil else {
                    PTGDataLogger.log("localSDP가 이미 있어요!")
                    return
                }
                
            self.webRTCService.set(remoteSdp: remoteSDP) { error in
                PTGDataLogger.log("remoteSDP가 저장되었어요!")

                if let error { PTGDataLogger.log(error.localizedDescription) }
                
                self.webRTCService.answer { sdp in
                    self.signalingService.send(
                        type: .answerSDP,
                        sdp: sdp,
                        roomID: userInfo.roomID,
                        offerID: userInfo.id,
                        answerID: sdpMessage.answerID
                    )
                }
            }
        }.store(in: &cancellables)
        
        self.signalingService.didReceiveAnswerSdpPublisher
            .filter { [weak self] _ in self?.remoteUserInfo != nil }
            .sink { [weak self] sdpMessage in
                guard let self else { return }
                let remoteSDP = sdpMessage.rtcSessionDescription
                
                guard let userInfo = remoteUserInfo else {
                    PTGDataLogger.log("UserInfo가 없어요")
                    return
                }
                
                guard userInfo.id == sdpMessage.answerID else {
                    return
                }
                
                guard self.webRTCService.peerConnection.localDescription != nil else {
                    PTGDataLogger.log("localDescription이 없어요")
                    return
                }
                
                guard self.webRTCService.peerConnection.remoteDescription == nil else {
                    PTGDataLogger.log("remoteDescription이 있어요")
                    return
                }
                
                self.webRTCService.set(remoteSdp: remoteSDP) { error in
                    if let error = error {
                        PTGDataLogger.log("Error setting remote SDP: \(error.localizedDescription)")
                    }
                }
            }.store(in: &cancellables)
        
        self.signalingService.didReceiveCandidatePublisher.sink { [weak self] candidate in
            guard let self else { return }
            self.webRTCService.set(remoteCandidate: candidate) { _ in }
        }.store(in: &cancellables)
    }
    
    private func bindLocalVideo() {
        self.clients.forEach { $0.bindLocalVideo(_localVideoView) }
    }
    
    private func bindNotifyNewUserPublihser() {
        roomService.notifyRoomResponsePublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    PTGDataLogger.log(error.localizedDescription)
                }
            }, receiveValue: {  [weak self] entity in
                guard let self else { return }
                let newUser = entity.newUser
                let emptyClient = clients.first(where: { $0.remoteUserInfo == nil })
                
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
                
                emptyClient?.setRemoteUserInfo(newUserInfoEntity)
                PTGDataLogger.log("newUser Entered: \(newUserInfoEntity)")
            })
            .store(in: &cancellables)
    }
    
    private func setLocalUserInfo(entity: JoinRoomEntity) -> Bool {
        guard let localUserInfo = localUserInfo(for: entity) else { return false }
        self.localUserInfo = localUserInfo
        return true
    }
    
    private func setLocalUserInfo(entity: RoomOwnerEntity) -> RoomOwnerEntity {
        guard let localUserInfo = localUserInfo(for: entity) else { return entity }
        self.localUserInfo = localUserInfo
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
            nickname: "내가 호스트다",
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
