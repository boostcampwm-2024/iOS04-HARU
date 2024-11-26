import Foundation
import Combine
import PhotoGetherDomainInterface

public final class CreateRoomUseCaseImpl: CreateRoomUseCase {
    private let inviteMessage = "PhotoGether 앱에서 초대를 보냈습니다.\n같이 사진 찍어요! 📷\n"
    
    public func execute() -> AnyPublisher<String, any Error> {
        connectionRepository.roomService.createRoom()
            .map { [weak self] in
                let message = self?.inviteMessage ?? ""
                let scheme = "photoGether://createRoom?roomID=\($0.roomID)&hostID=\($0.hostID)"
                return message + scheme
            }
            .eraseToAnyPublisher()
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
