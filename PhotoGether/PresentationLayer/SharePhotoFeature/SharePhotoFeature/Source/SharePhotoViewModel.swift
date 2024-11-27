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
        case showAuthorizationAlert
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
                self?.output.send(.showShareSheet)
            case .saveButtonDidTap:
                Task { await self?.handleSaveButtonDidTap() }
            }
        }
        .store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    private func handleSaveButtonDidTap() async {
        guard await isAuthorized() else {
            output.send(.showAuthorizationAlert)
            return
        }
        
        let isSuccess = await savePhoto()
        output.send(isSuccess ? .showSaveToast : .showFailToast)
    }
    
    private func savePhoto() async -> Bool {
        return await PhotoLibraryHelper.savePhoto(with: photoData)
    }
    
    private func isAuthorized() async -> Bool {
        return await PhotoLibraryPermissionManager.checkPhotoPermission()
    }
}
