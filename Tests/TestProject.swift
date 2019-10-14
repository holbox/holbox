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
    
    func testContentCard() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        let time = Date()
        session.add(0)
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        session.add(0, list: 0)
        store.session = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertEqual("hello world", $0.cards[0].1.first)
            expectProject.fulfill()
        }
        session.content(0, list: 0, card: 0, content: "hello world")
        waitForExpectations(timeout: 1)
    }
}
