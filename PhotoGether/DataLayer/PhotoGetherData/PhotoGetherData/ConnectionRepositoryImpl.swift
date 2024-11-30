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
    
    public init(clients: [ConnectionClient], roomService: RoomService) {
        self.clients = clients
        self.roomService = roomService
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
    
    public func sendOffer() -> Bool {
        guard let myID = localUserInfo?.id else { return false }
        clients.forEach { $0.sendOffer(myID: myID) }
        return true
    }
}

extension ConnectionRepositoryImpl {
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
