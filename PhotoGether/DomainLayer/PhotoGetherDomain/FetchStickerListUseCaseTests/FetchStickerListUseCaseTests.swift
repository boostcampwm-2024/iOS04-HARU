import XCTest
import PhotoGetherDomainTesting
import PhotoGetherDomainInterface
import PhotoGetherDomain

final class FetchStickerListUseCaseTests: XCTestCase {
    var sut: FetchStickerListUseCase!
    var shapeRepositoryMock: ShapeRepositoryMock!
    
    func test_이미지데이터_리스트를_번들에서_잘_가져오는지() {
        //Arrange 준비 단계: 테스트 대상 시스템(SUT)와 의존성을 원하는 상태로 만들기
        let expectation = XCTestExpectation(description: "이미지 데이터 리스트 가져오기 테스트")
        let imageNameList = [
            "blackHeart",
            "bug",
            "cat",
            "crown",
            "dog",
            "lips",
            "parkBug",
            "racoon",
            "redHeart",
            "star",
            "sunglasses",
            "tree",
        ]
        let shapeRepositoryMock = ShapeRepositoryMock(imageNameList: imageNameList)
        
        sut = FetchStickerListUseCaseImpl(shapeRepository: shapeRepositoryMock)
        
        var targetDataList: [Data] = []
        let beforeDataListCount = 0
        
        //Act 실행 단계: SUT 메소드를 호출하면서 의존성을 전달해서 결과를 저장하기
        let cancellable = sut.execute()
            .sink { datas in
                targetDataList.append(contentsOf: datas)
                expectation.fulfill()
            }
        
        //Assert 검증 단계: 결과와 기대치를 비교해서 검증하기
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(beforeDataListCount, 0)
        XCTAssertEqual(targetDataList.count, 12)
        
        cancellable.cancel()
    }
}
