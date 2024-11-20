import XCTest
import PhotoGetherDomainInterface
import PhotoGetherDomainTesting

final class CountClientsUseCaseTests: XCTestCase {
    var sut: CountClientsUseCase!
    
    func test_클라이언트_수를_잘_가져오는지() {
        for i in 0..<10 {
            sut = CountClientsUseCaseMock(clientCount: i)
            XCTAssertEqual(sut.execute(), i)
        }
    }
}
