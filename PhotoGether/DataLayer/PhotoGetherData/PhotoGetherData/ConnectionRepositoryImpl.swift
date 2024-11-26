import UIKit
import Combine
import PhotoGetherDomainInterface

public final class ConnectionRepositoryImpl: ConnectionRepository {
    public var clients: [ConnectionClient]
    
    private let _localVideoView = CapturableVideoView()
    private var localUserInfo: UserInfoEntity?
    
    public var localVideoView: UIView { _localVideoView }
    public var capturedLocalVideo: UIImage? { _localVideoView.capturedImage }
    
    private let roomService: RoomService
    
    public init(clients: [ConnectionClient], roomService: RoomService) {
        self.clients = clients
        self.roomService = roomService
        bindLocalVideo()
    }
    
    private func bindLocalVideo() {
        self.clients.forEach { $0.bindLocalVideo(_localVideoView) }
    }
    
    public func createRoom() -> AnyPublisher<RoomOwnerEntity, Error> {
        return roomService.createRoom()
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
    
    private func setLocalUserInfo(entity: JoinRoomEntity) -> Bool {
        guard let localUserInfo = localUserInfo(for: entity) else { return false }
        self.localUserInfo = localUserInfo
        return true
    }
    
    private func setRemoteUserInfo(entity: JoinRoomEntity, hostID: String) -> Bool {
        let remoteUserInfoList = remoteUserInfoList(for: entity, hostID: hostID)
        
        for (idx, userInfo) in remoteUserInfoList.enumerated() {
            clients[idx].setRemoteUserInfo(userInfo)
        }
        return true
    }
    
    private func localUserInfo(for entity: JoinRoomEntity) -> UserInfoEntity? {
        let myID = entity.userID
        let clientsInfo = entity.userList
        guard let myInfo = clientsInfo.first(where: { $0.userID == myID }),
              let viewPosition = UserInfoEntity.ViewPosition(rawValue: myInfo.initialPosition)
        else { return nil }
        
        return UserInfoEntity(
            id: myInfo.userID,
            nickname: myInfo.nickname,
            isHost: false,
            viewPosition: viewPosition
        )
    }
    
    private func remoteUserInfoList(for entity: JoinRoomEntity, hostID: String) -> [UserInfoEntity] {
        var result: [UserInfoEntity] = []
        let clientsInfo = entity.userList.filter { $0.userID != entity.userID }
        result = clientsInfo.map {
            let userID = $0.userID
            guard let userInfo = clientsInfo.first(where: { $0.userID == userID }),
                  let viewPosition = UserInfoEntity.ViewPosition(rawValue: userInfo.initialPosition)
            else { return nil }
            let isHost = userID == hostID
            
            return UserInfoEntity(
                id: userInfo.userID,
                nickname: userInfo.nickname,
                isHost: isHost,
                viewPosition: viewPosition
            )
        }.compactMap { $0 }

        return result
    }
}
