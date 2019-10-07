@testable import holbox
import XCTest

final class TestSession: XCTestCase {
    private var session: Session!
    private var store: StubStore!
    
    override func setUp() {
        session = .init()
        store = .init()
        session.store = store
    }
    
    func testRating() {
        XCTAssertGreaterThanOrEqual(Calendar.current.date(byAdding: .day, value: 2, to: .init())!, session.rating)
        XCTAssertFalse(session.rate)
        session.rating = Calendar.current.date(byAdding: .second, value: -1, to: .init())!
        XCTAssertTrue(session.rate)
        session.rated()
        XCTAssertFalse(session.rate)
        XCTAssertGreaterThanOrEqual(Calendar.current.date(byAdding: .month, value: 3, to: .init())!, session.rating)
    }
    
    func testSaveOnRate() {
        let expect = expectation(description: "")
        store.session = {
            XCTAssertEqual(self.session.rating, $0.rating)
            expect.fulfill()
        }
        session.rated()
        waitForExpectations(timeout: 1)
    }
    
    func testAdd() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        session.projects = [.init()]
        session.counter = 77
        store.session = {
            XCTAssertEqual(1, $0.projects(.kanban).count)
            XCTAssertEqual("",  $0.name($0.projects(.kanban).last!))
            XCTAssertEqual(78, $0.counter)
            XCTAssertEqual(1, $0.projects(.kanban).last)
            XCTAssertEqual(.kanban, $0.projects.last?.mode)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertEqual(77, $0.id)
            expectProject.fulfill()
        }
        session.add(.kanban)
        waitForExpectations(timeout: 1)
    }
}
