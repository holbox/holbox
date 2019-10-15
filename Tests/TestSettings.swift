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
        store.session = {
            XCTAssertFalse($0.settings.spell)
            XCTAssertFalse($1)
            expect.fulfill()
        }
        session.spell(false)
        waitForExpectations(timeout: 1)
    }
}
