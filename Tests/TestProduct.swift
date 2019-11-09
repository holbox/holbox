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
            XCTAssertEqual(1, $1.cards[1].1.count)
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
    
    func testContains() {
        XCTAssertFalse(session.contains(0, reference: 0))
        session.add(0, emoji: "🐷", description: "piggy")
        session.add(0, reference: 0)
        XCTAssertTrue(session.contains(0, reference: 0))
    }
    
    func testUpdate() {
        session.add(0, emoji: "🐷", description: "piggy")
        session.product(0, index: 0, emoji: "🦊", description: "fox")
        XCTAssertEqual(1, session.cards(0, list: 0))
        XCTAssertEqual("🦊", session.product(0, index: 0).0)
        XCTAssertEqual("fox", session.product(0, index: 0).1)
    }
    
    func testUpdateSaves() {
        let expect = expectation(description: "")
        let time = Date()
        session.add(0, emoji: "🐷", description: "piggy")
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertTrue($1.cards[0].1[0].contains("🦊"))
            expect.fulfill()
        }
        session.product(0, index: 0, emoji: "🦊", description: "fox")
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateSameNotSave() {
        session.add(0, emoji: "🐷", description: "piggy")
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.session = { _ in XCTFail() }
        store.project = { _, _ in XCTFail() }
        session.product(0, index: 0, emoji: "🐷", description: "piggy")
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0].time)
    }
    
    func testDelete() {
        session.add(0, emoji: "🐷", description: "piggy")
        session.add(0, reference: 0)
        session.delete(0, product: 0)
        XCTAssertEqual(0, session.cards(0, list: 0))
        XCTAssertEqual(0, session.cards(0, list: 1))
    }
    
    func testDeleteSaves() {
        let expect = expectation(description: "")
        let time = Date()
        session.add(0, emoji: "🐷", description: "piggy")
        session.add(0, reference: 0)
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertEqual(0, $1.cards[0].1.count)
            XCTAssertEqual(0, $1.cards[1].1.count)
            expect.fulfill()
        }
        session.delete(0, product: 0)
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteUpdatesReferences() {
        session.add(0, emoji: "🐷", description: "piggy")
        session.add(0, emoji: "🦊", description: "fox")
        session.add(0, emoji: "🐱", description: "cat")
        session.add(0, emoji: "🐷", description: "piggy2")
        session.add(0, emoji: "🐷", description: "piggy3")
        session.add(0, emoji: "🐷", description: "piggy4")
        session.add(0, emoji: "🐷", description: "piggy5")
        session.add(0, emoji: "🐷", description: "piggy6")
        session.add(0, emoji: "🐷", description: "piggy7")
        session.add(0, reference: 2)
        session.add(0, reference: 3)
        session.add(0, reference: 4)
        session.add(0, reference: 5)
        session.add(0, reference: 6)
        session.add(0, reference: 1)
        session.add(0, reference: 0)
        session.add(0, reference: 7)
        session.add(0, reference: 8)
        session.delete(0, product: 1)
        XCTAssertEqual(8, session.cards(0, list: 0))
        XCTAssertEqual(8, session.cards(0, list: 1))
        XCTAssertEqual("1", session.content(0, list: 1, card: 0))
        XCTAssertEqual("2", session.content(0, list: 1, card: 1))
        XCTAssertEqual("3", session.content(0, list: 1, card: 2))
        XCTAssertEqual("4", session.content(0, list: 1, card: 3))
        XCTAssertEqual("5", session.content(0, list: 1, card: 4))
        XCTAssertEqual("0", session.content(0, list: 1, card: 5))
        XCTAssertEqual("6", session.content(0, list: 1, card: 6))
        XCTAssertEqual("7", session.content(0, list: 1, card: 7))
    }
}
