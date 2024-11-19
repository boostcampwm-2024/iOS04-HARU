import Combine
import Foundation

public protocol FetchStickerListUseCase {
    func execute() -> AnyPublisher<[Data], Never>
}
