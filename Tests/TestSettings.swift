@testable import holbox
import XCTest

final class TestSettings: XCTestCase {
    private var session: Session!
    private var store: StubStore!
    
    override func setUp() {
        session = .init()
        store = .init()
        session.store = store
    }
    
    func testSaveOnSpell() {
        let expect = expectation(description: "")
        store.save = {
            XCTAssertFalse($0.settings.spell)
            expect.fulfill()
        }
        store.share = { _ in XCTFail() }
        session.spell(false)
        waitForExpectations(timeout: 1)
    }
}
