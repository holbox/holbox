@testable import holbox
import XCTest

final class TestGrocery: XCTestCase {
    private var session: Session!
    private var store: StubStore!
    
    override func setUp() {
        store = .init()
        session = .init()
        session.store = store
        _ = session.add(.shopping)
    }
    
    func testAdd() {
        session.add(0, emoji: "🐱 ", grocery: "hello ")
        XCTAssertEqual("🐱", session.items[0]!.cards[0].1[0])
        XCTAssertEqual("hello", session.items[0]!.cards[1].1[0])
        XCTAssertEqual("0", session.items[0]!.cards[2].1[0])
    }
    
    func testAddSaves() {
        let expect = expectation(description: "")
        let time = Date()
        session.items[0]!.time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.items[0]!.time)
            XCTAssertEqual(1, $2.cards[0].1.count)
            expect.fulfill()
        }
        session.add(0, emoji: "🐱 ", grocery: "hello ")
        waitForExpectations(timeout: 1)
    }
    
    func testDelete() {
        let expect = expectation(description: "")
        let time = Date()
        session.items[0]!.cards = [("", ["🐱"]), ("", ["hello"]), ("", ["0"])]
        session.items[0]!.time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.items[0]!.time)
            XCTAssertTrue($2.cards[0].1.isEmpty)
            XCTAssertTrue($2.cards[1].1.isEmpty)
            XCTAssertTrue($2.cards[2].1.isEmpty)
            expect.fulfill()
        }
        session.delete(0, grocery: 0)
        waitForExpectations(timeout: 1)
    }
}
