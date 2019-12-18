@testable import holbox
import XCTest

final class TestMigrate: XCTestCase {
    private var session: Session!
    private var store: StubStore!
    
    override func setUp() {
        store = .init()
        session = .init()
        session.store = store
    }
    
    func testTodo() {
        let date = Int(Date().timeIntervalSince1970)
        _ = session.add(.todo)
        session.items[0]!.cards = [("", []), ("", ["hello"])]
        session.migrate()
        XCTAssertGreaterThanOrEqual(Int(session.items[0]!.cards[2].1[0])!, date)
    }
    
    func testTodoSaves() {
        let expect = expectation(description: "")
        let time = Date()
        _ = session.add(.todo)
        session.items[0]!.time = .init(timeIntervalSince1970: 0)
        session.items[0]!.cards = [("", []), ("", ["hello"])]
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.items[0]!.time)
            XCTAssertEqual(1, $2.cards[2].1.count)
            expect.fulfill()
        }
        session.migrate()
        waitForExpectations(timeout: 1)
    }
    
    func testMigratedTodoNotMigrate() {
        _ = session.add(.todo)
        session.items[0]!.cards = [("", []), ("", ["hello"]), ("", ["0"])]
        store.session = { _ in XCTFail() }
        store.project = { _, _, _ in XCTFail() }
        session.migrate()
        XCTAssertEqual(3, session.items[0]!.cards.count)
    }
    
    func testKanbanShoppingNotesNotMigrate() {
        _ = session.add(.kanban)
        _ = session.add(.notes)
        store.session = { _ in XCTFail() }
        store.project = { _, _, _ in XCTFail() }
        session.migrate()
    }
    
    func testShopping() {
        _ = session.add(.shopping)
        session.items[0]!.cards = [("", ["🐷\npiggy", "🦊\nfox"]), ("", ["0"])]
        session.migrate()
        XCTAssertEqual("🐷", session.items[0]!.cards[0].1[0])
        XCTAssertEqual("🦊", session.items[0]!.cards[0].1[1])
        XCTAssertEqual("piggy", session.items[0]!.cards[1].1[0])
        XCTAssertEqual("fox", session.items[0]!.cards[1].1[1])
        XCTAssertEqual("0", session.items[0]!.cards[2].1[0])
        XCTAssertEqual("1", session.items[0]!.cards[2].1[1])
    }
}
