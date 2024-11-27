import Combine
import Foundation
import PhotoGetherDomainInterface

public final class SharePhotoViewModel {
    enum Input {
        case shareButtonDidTap
        case saveButtonDidTap
    }
    
    enum Output {
        case showShareSheet
    }
    
    public private(set) var photoData: Data
    
    private let output = PassthroughSubject<Output, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(component: SharePhotoComponent) {
        self.photoData = component.photoData
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .shareButtonDidTap:
            case .saveButtonDidTap:
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
}
