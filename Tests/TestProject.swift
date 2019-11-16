@testable import holbox
import XCTest

final class TestProject: XCTestCase {
    private var session: Session!
    private var store: StubStore!
    
    override func setUp() {
        store = .init()
        session = .init()
        session.store = store
        var project = Project()
        project.mode = .kanban
        session.projects[0] = project
    }
    
    func testAddList() {
        let expect = expectation(description: "")
        let time = Date()
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0]!.time)
            XCTAssertLessThanOrEqual(time, $2.time)
            XCTAssertEqual(1, $2.cards.count)
            expect.fulfill()
        }
        session.add(0)
        waitForExpectations(timeout: 1)
    }
    
    func testName() {
        let expect = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0]!.time)
            XCTAssertEqual("hello world", $2.name)
            expect.fulfill()
        }
        session.name(0, name: "hello world")
        waitForExpectations(timeout: 1)
    }
    
    func testNameList() {
        let expect = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0]!.time)
            XCTAssertEqual("hello world", $2.cards[0].0)
            expect.fulfill()
        }
        session.name(0, list: 0, name: "hello world")
        waitForExpectations(timeout: 1)
    }
    
    func testAddCard() {
        let expect = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0]!.time)
            XCTAssertEqual(2, $2.cards[0].1.count)
            XCTAssertEqual("", $2.cards[0].1.first)
            expect.fulfill()
        }
        session.projects[0]!.cards = [("", ["hello"])]
        session.add(0, list: 0)
        waitForExpectations(timeout: 1)
    }
    
    func testAddCardContent() {
        let expect = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0]!.time)
            XCTAssertEqual(2, $2.cards[0].1.count)
            XCTAssertEqual("world", $2.cards[0].1.first)
            expect.fulfill()
        }
        session.projects[0]!.cards = [("world", ["hello"])]
        session.add(0, list: 0, content: "world")
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteCard() {
        let expect = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0]!.time)
            XCTAssertEqual(3, $2.cards[0].1.count)
            XCTAssertEqual("lorem", $2.cards[0].1[1])
            expect.fulfill()
        }
        session.projects[0]!.cards = [("", ["hello", "world", "lorem", "ipsum"])]
        session.delete(0, list: 0, card: 1)
        waitForExpectations(timeout: 1)
    }
    
    func testContent() {
        let expect = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        session.add(0, list: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0]!.time)
            XCTAssertEqual("hello world", $2.cards[0].1.first)
            expect.fulfill()
        }
        session.content(0, list: 0, card: 0, content: "hello world")
        waitForExpectations(timeout: 1)
    }
    
    func testMove() {
        let expect = expectation(description: "")
        let time = Date()
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        session.projects[0]!.cards = [("", ["hello", "world"])]
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0]!.time)
            XCTAssertEqual("world", $2.cards[0].1.first)
            XCTAssertEqual("hello", $2.cards[0].1.last)
            XCTAssertEqual(2, $2.cards[0].1.count)
            expect.fulfill()
        }
        session.move(0, list: 0, card: 0, destination: 0, index: 1)
        waitForExpectations(timeout: 1)
    }
    
    func testNameSame() {
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        session.projects[0]!.name = "hello world"
        store.session = { _ in XCTFail() }
        store.project = { _, _, _ in XCTFail() }
        session.name(0, name: "hello world")
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0]!.time)
    }
    
    func testListNameSame() {
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        session.projects[0]!.cards = [("hello world", [])]
        store.session = { _ in XCTFail() }
        store.project = { _, _, _ in XCTFail() }
        session.name(0, list: 0, name: "hello world")
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0]!.time)
    }
    
    func testContentSame() {
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        session.projects[0]!.cards = [("", ["hello world"])]
        store.session = { _ in XCTFail() }
        store.project = { _, _, _ in XCTFail() }
        session.content(0, list: 0, card: 0, content: "hello world")
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0]!.time)
    }
    
    func testMoveSame() {
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        session.projects[0]!.cards = [("", ["hello", "world"])]
        store.session = { _ in XCTFail() }
        store.project = { _, _, _ in XCTFail() }
        session.move(0, list: 0, card: 1, destination: 0, index: 1)
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0]!.time)
    }
    
    func testNameTrim() {
        session.projects[0]!.name = "abc"
        session.name(0, name: "hello\nworld")
        XCTAssertEqual("helloworld", session.projects[0]!.name)
    }
    
    func testListNameTrim() {
        session.projects[0]!.cards = [("abc", [])]
        session.name(0, list: 0, name: "hello\nworld")
        XCTAssertEqual("helloworld", session.projects[0]!.cards[0].0)
    }
}
