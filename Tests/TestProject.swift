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
        session.projects = [project]
    }
    
    func testAddList() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        let time = Date()
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.session = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertTrue($1)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.time)
            XCTAssertEqual(1, $0.cards.count)
            expectProject.fulfill()
        }
        session.add(0)
        waitForExpectations(timeout: 1)
    }
    
    func testName() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.session = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertTrue($1)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertEqual("hello world", $0.name)
            expectProject.fulfill()
        }
        session.name(0, name: "hello world")
        waitForExpectations(timeout: 1)
    }
    
    func testNameList() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.session = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertTrue($1)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertEqual("hello world", $0.cards[0].0)
            expectProject.fulfill()
        }
        session.name(0, list: 0, name: "hello world")
        waitForExpectations(timeout: 1)
    }
    
    func testAddCard() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.session = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertTrue($1)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertEqual(2, $0.cards[0].1.count)
            XCTAssertEqual("", $0.cards[0].1.first)
            expectProject.fulfill()
        }
        session.projects[0].cards = [("", ["hello"])]
        session.add(0, list: 0)
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteCard() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.session = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertTrue($1)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertEqual(3, $0.cards[0].1.count)
            XCTAssertEqual("lorem", $0.cards[0].1[1])
            expectProject.fulfill()
        }
        session.projects[0].cards = [("", ["hello", "world", "lorem", "ipsum"])]
        session.delete(0, list: 0, card: 1)
        waitForExpectations(timeout: 1)
    }
    
    func testContent() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        session.add(0, list: 0)
        store.session = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertTrue($1)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertEqual("hello world", $0.cards[0].1.first)
            expectProject.fulfill()
        }
        session.content(0, list: 0, card: 0, content: "hello world")
        waitForExpectations(timeout: 1)
    }
    
    func testMove() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        let time = Date()
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        session.projects[0].cards = [("", ["hello", "world"])]
        store.session = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertTrue($1)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertEqual("world", $0.cards[0].1.first)
            XCTAssertEqual("hello", $0.cards[0].1.last)
            XCTAssertEqual(2, $0.cards[0].1.count)
            expectProject.fulfill()
        }
        session.move(0, list: 0, card: 0, destination: 0, index: 1)
        waitForExpectations(timeout: 1)
    }
    
    func testNameSame() {
        session.projects = [.init()]
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        session.projects[0].name = "hello world"
        store.session = { _, _ in XCTFail() }
        store.project = { _ in XCTFail() }
        session.name(0, name: "hello world")
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0].time)
    }
    
    func testListNameSame() {
        session.projects = [.init()]
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        session.projects[0].cards = [("hello world", [])]
        store.session = { _, _ in XCTFail() }
        store.project = { _ in XCTFail() }
        session.name(0, list: 0, name: "hello world")
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0].time)
    }
    
    func testContentSame() {
        session.projects = [.init()]
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        session.projects[0].cards = [("", ["hello world"])]
        store.session = { _, _ in XCTFail() }
        store.project = { _ in XCTFail() }
        session.content(0, list: 0, card: 0, content: "hello world")
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0].time)
    }
    
    func testMoveSame() {
        session.projects = [.init()]
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        session.projects[0].cards = [("", ["hello", "world"])]
        store.session = { _, _ in XCTFail() }
        store.project = { _ in XCTFail() }
        session.move(0, list: 0, card: 1, destination: 0, index: 1)
        XCTAssertEqual(.init(timeIntervalSince1970: 0), session.projects[0].time)
    }
}
