import Foundation
import UIKit
import PhotoGetherDomainInterface

public final class GetLocalVideoUseCaseImpl: GetLocalVideoUseCase {
    public func execute() -> UIView {
        // TODO: 리포지토리에서 하나의 localVideoView만 들고 있도록 변경 예정
        connectionRepository.localVideoView
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
}
