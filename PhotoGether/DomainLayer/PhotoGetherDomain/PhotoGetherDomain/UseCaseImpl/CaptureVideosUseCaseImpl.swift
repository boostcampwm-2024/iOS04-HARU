import UIKit
import PhotoGetherDomainInterface
import DesignSystem

public final class CaptureVideosUseCaseImpl: CaptureVideosUseCase {
    public func execute() -> [UIImage] {
        let localImage = connectionRepository.capturedLocalVideo ?? UIImage()
        
        let localUserImageInfo = [(connectionRepository.localUserInfo?.viewPosition, localImage)]
        let remoteUserImagesInfo = connectionRepository.clients
            .map { ($0.remoteUserInfo?.viewPosition, $0.captureVideo()) }
        
        return sortImages(localUserImageInfo + remoteUserImagesInfo)
    }
    
    private let connectionRepository: ConnectionRepository
    
    public init(connectionRepository: ConnectionRepository) {
        self.connectionRepository = connectionRepository
    }
    
    private func sortImages(_ images: [(viewPosition: UserInfo.ViewPosition?, image: UIImage)]) -> [UIImage] {
        let convertedArray = images.map {
            (position: PositionOder(rawValue: $0.viewPosition?.rawValue ?? -1),
             image: $0.image)
        }
        
        // 배열의 2번 인덱스가 마지막 자리이기 때문에 nil일 경우 2로 설정했습니다
        let sortedByViewPosition = convertedArray.sorted {
            let lhs = $0.position?.sequence ?? 2
            let rhs = $1.position?.sequence ?? 2
            return lhs < rhs
        }
        
        return sortedByViewPosition.map { $0.image }
    }
}

// case의 순서는 참가자의 참가 순서에 따른 화면 배치이고 sequence는 이미지 데이터 전달할 때의 배열 순서입니다
private enum PositionOder: Int {
    case topLeading
    case bottomTrailing
    case topTrailing
    case bottomLeading
    
    var sequence: Int {
        switch self {
        case .topLeading: 0
        case .topTrailing: 1
        case .bottomLeading: 2
        case .bottomTrailing: 3
        }
    }
}
