@testable import holbox
import XCTest

final class TestPerks: XCTestCase {
    private var session: Session!
    private var store: StubStore!
    
    override func setUp() {
        session = .init()
        store = .init()
        session.store = store
    }
    
    func testPurchase() {
        let expect = expectation(description: "")
        store.save = {
            XCTAssertEqual(.two, $0.perks.first)
            expect.fulfill()
        }
        store.share = { _ in XCTFail() }
        session.purchase(.two)
        XCTAssertEqual(3, session.available)
        waitForExpectations(timeout: 1)
    }
    
    func testNoDuplicates() {
        session.purchase(.two)
        session.purchase(.two)
        XCTAssertEqual(1, session.perks.count)
    }
}
