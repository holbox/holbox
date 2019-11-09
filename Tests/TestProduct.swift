@testable import holbox
import XCTest

final class TestProduct: XCTestCase {
    private var session: Session!
    private var store: StubStore!
    
    override func setUp() {
        store = .init()
        session = .init()
        session.store = store
        session.add(.shopping)
    }
    
    func testAddEmptyBoth() {
        session.add(0, emoji: "", description: "")
        XCTAssertEqual(0, session.cards(0, list: 0))
    }
    
    func testAddEmptyEmpji() {
        session.add(0, emoji: "", description: "a")
        XCTAssertEqual(1, session.cards(0, list: 0))
        XCTAssertEqual("a", session.product(0, index: 0).1)
    }
}
