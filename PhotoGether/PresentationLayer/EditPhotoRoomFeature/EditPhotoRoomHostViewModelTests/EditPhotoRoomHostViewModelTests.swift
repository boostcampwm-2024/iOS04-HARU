import XCTest
import EditPhotoRoomFeature
import FeatureTesting

final class EditPhotoRoomHostViewModelTests: XCTestCase {
    var sut: EditPhotoRoomHostViewModel!
    
    override func setUp() {
        super.setUp()
        
        let fetchStickerListUseCaseMock = FetchStickerListUseCaseMock()
        sut = EditPhotoRoomHostViewModel(fetchStickerListUseCase: fetchStickerListUseCaseMock)
    }
}
