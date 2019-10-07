@testable import holbox
import XCTest

final class TestProject: XCTestCase {
    private var session: Session!
    private var store: StubStore!
    
    override func setUp() {
        store = .init()
        session = .init()
        session.store = store
        session.add(.kanban)
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
            XCTAssertEqual(1, $0.lists.count)
            expectProject.fulfill()
        }
        session.add(0)
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
            XCTAssertEqual("hello world", $0.lists[0].name)
            expectProject.fulfill()
        }
        se
        waitForExpectations(timeout: 1)
    }
    
    func testSaveOnAddCard() {
        let expect = expectation(description: "")
        project.add()
        store.project = {
            XCTAssertEqual(1, $0.count(0))
            expect.fulfill()
        }
        project.add(0)
        waitForExpectations(timeout: 1)
    }
    
    func testSaveOnEditCard() {
        let expect = expectation(description: "")
        project.add()
        project.add()
        project.add()
        project.add(1)
        project.add(1)
        project.add(1)
        project.edit(1, 2, content: "hello world")
        store.project = {
            XCTAssertEqual("hello world", $0.content(1, 2))
            XCTAssertEqual("lorem ipsum", $0.content(1, 1))
            expect.fulfill()
        }
        project.edit(1, 1, content: "lorem ipsum")
        waitForExpectations(timeout: 1)
    }
}
