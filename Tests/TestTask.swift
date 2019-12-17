@testable import holbox
import XCTest

final class TestTask: XCTestCase {
    private var session: Session!
    private var store: StubStore!
    
    override func setUp() {
        store = .init()
        session = .init()
        session.store = store
        _ = session.add(.todo)
    }
    
    func testCompleted() {
        let date = Int(Date().timeIntervalSince1970)
        session.items[0]!.cards = [("", ["hello"]), ("", []), ("", [])]
        session.completed(0, index: 0)
        XCTAssertTrue(session.items[0]!.cards[0].1.isEmpty)
        XCTAssertEqual("hello", session.items[0]!.cards[1].1[0])
        XCTAssertGreaterThanOrEqual(Int(session.items[0]!.cards[2].1[0])!, date)
    }
    
    func testCompletedSaves() {
        let expect = expectation(description: "")
        let time = Date()
        session.items[0]!.time = .init(timeIntervalSince1970: 0)
        session.items[0]!.cards = [("", ["hello"]), ("", []), ("", [])]
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.items[0]!.time)
            XCTAssertEqual(1, $2.cards[1].1.count)
            expect.fulfill()
        }
        session.completed(0, index: 0)
        waitForExpectations(timeout: 1)
    }
    
    func testRestart() {
        session.items[0]!.cards = [("", []), ("", ["hello"]), ("", ["0"])]
        session.restart(0, index: 0)
        XCTAssertTrue(session.items[0]!.cards[1].1.isEmpty)
        XCTAssertTrue(session.items[0]!.cards[2].1.isEmpty)
        XCTAssertEqual("hello", session.items[0]!.cards[0].1[0])
    }
    
    func testRestartSaves() {
        let expect = expectation(description: "")
        let time = Date()
        session.items[0]!.time = .init(timeIntervalSince1970: 0)
        session.items[0]!.cards = [("", []), ("", ["hello"]), ("", ["0"])]
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.items[0]!.time)
            XCTAssertEqual(1, $2.cards[0].1.count)
            expect.fulfill()
        }
        session.restart(0, index: 0)
        waitForExpectations(timeout: 1)
    }
}
