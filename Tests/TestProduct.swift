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
    
    func testAddWhiteSpaces() {
        session.add(0, emoji: " ", description: " ")
        XCTAssertEqual(0, session.cards(0, list: 0))
    }
    
    func testAddEmptyNotSave() {
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.session = { _ in XCTFail() }
        store.project = { _, _ in XCTFail() }
        session.add(0, emoji: "", description: "")
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0].time)
    }
    
    func testAddEmptyEmoji() {
        session.add(0, emoji: "", description: "a")
        XCTAssertEqual(1, session.cards(0, list: 0))
        XCTAssertEqual("a", session.product(0, index: 0).1)
    }
    
    func testAddEmptyDescription() {
        session.add(0, emoji: "🐷", description: "")
        XCTAssertEqual(1, session.cards(0, list: 0))
        XCTAssertEqual("🐷", session.product(0, index: 0).0)
    }
    
    func testAdd() {
        session.add(0, emoji: "🐷", description: "piggy")
        XCTAssertEqual(1, session.cards(0, list: 0))
        XCTAssertEqual("🐷", session.product(0, index: 0).0)
        XCTAssertEqual("piggy", session.product(0, index: 0).1)
    }
    
    func testAddSecond() {
        session.add(0, emoji: "🐷", description: "piggy")
        session.add(0, emoji: "🦊", description: "fox")
        XCTAssertEqual(2, session.cards(0, list: 0))
        XCTAssertEqual("🐷", session.product(0, index: 0).0)
        XCTAssertEqual("🦊", session.product(0, index: 1).0)
    }
    
    func testAddStrip() {
        session.add(0, emoji: "🐷  \n", description: "piggy\n    \n\t")
        XCTAssertEqual(1, session.cards(0, list: 0))
        XCTAssertEqual("🐷", session.product(0, index: 0).0)
        XCTAssertEqual("piggy", session.product(0, index: 0).1)
    }
    
    func testAddNonEmoji() {
        session.add(0, emoji: "h", description: "piggy")
        XCTAssertEqual(1, session.cards(0, list: 0))
        XCTAssertTrue(session.product(0, index: 0).0.isEmpty)
        XCTAssertEqual("piggy", session.product(0, index: 0).1)
    }
    
    func testAddSaves() {
        let expect = expectation(description: "")
        let time = Date()
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertEqual(1, $1.cards[0].1.count)
            expect.fulfill()
        }
        session.add(0, emoji: "", description: "a")
        waitForExpectations(timeout: 1)
    }
    
    func testAddReference() {
        session.add(0, emoji: "🐷", description: "piggy")
        session.add(0, emoji: "🦊", description: "fox")
        session.add(0, reference: 1)
        session.add(0, reference: 0)
        XCTAssertEqual(2, session.cards(0, list: 1))
        XCTAssertEqual("🐷", session.reference(0, index: 1).0)
        XCTAssertEqual("piggy", session.reference(0, index: 1).1)
        XCTAssertEqual("🦊", session.reference(0, index: 0).0)
        XCTAssertEqual("fox", session.reference(0, index: 0).1)
    }
    
    func testAddReferenceSaves() {
        let expect = expectation(description: "")
        let time = Date()
        session.add(0, emoji: "🐷", description: "piggy")
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertEqual(1, $1.cards[0].1.count)
            expect.fulfill()
        }
        session.add(0, reference: 0)
        waitForExpectations(timeout: 1)
    }
    
    func testAddReferenceDuplicate() {
        session.add(0, emoji: "🐷", description: "piggy")
        session.add(0, reference: 0)
        session.add(0, reference: 0)
        XCTAssertEqual(1, session.cards(0, list: 1))
    }
    
    func testAddReferenceDuplicatedNotSave() {
        session.add(0, emoji: "🐷", description: "piggy")
        session.add(0, reference: 0)
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.session = { _ in XCTFail() }
        store.project = { _, _ in XCTFail() }
        session.add(0, reference: 0)
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0].time)
    }
}
