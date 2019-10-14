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
    
    func testNoPerks() {
        XCTAssertEqual(1, session.available)
        XCTAssertEqual(1, session.capacity)
        session.projects = [.init()]
        session.projects[0].mode = .kanban
        XCTAssertEqual(0, session.available)
        XCTAssertEqual(1, session.capacity)
        session.projects[0].mode = .off
        XCTAssertEqual(1, session.available)
        XCTAssertEqual(1, session.capacity)
        session.projects = [.init(), .init()]
        session.projects[0].mode = .kanban
        session.projects[1].mode = .kanban
        XCTAssertEqual(0, session.available)
        XCTAssertEqual(1, session.capacity)
    }
    
    func testPerks() {
        session.perks = [.two]
        XCTAssertEqual(3, session.capacity)
        session.perks = [.two, .ten]
        XCTAssertEqual(13, session.capacity)
        session.perks = [.two, .ten, .hundred]
        XCTAssertEqual(113, session.capacity)
        session.perks = [.hundred]
        XCTAssertEqual(101, session.capacity)
        session.perks = [.ten]
        XCTAssertEqual(11, session.capacity)
        session.perks = [.hundred, .two]
        XCTAssertEqual(103, session.capacity)
    }
    
    func testAdd() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        session.projects = [.init()]
        session.counter = 77
        store.session = {
            XCTAssertEqual(1, $0.projects(.kanban).count)
            XCTAssertEqual(78, $0.counter)
            XCTAssertEqual(0, $0.projects(.kanban).first)
            XCTAssertEqual(77, $0.projects.first?.id)
            XCTAssertEqual(2, $0.projects.count)
            XCTAssertEqual(.kanban, $0.projects.first?.mode)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertEqual(77, $0.id)
            expectProject.fulfill()
        }
        session.add(.kanban)
        waitForExpectations(timeout: 1)
    }
    
    func testAddKanban() {
        session.add(.kanban)
        XCTAssertEqual(3, session.projects[0].cards.count)
        XCTAssertFalse(session.projects[0].name.isEmpty)
        XCTAssertFalse(session.projects[0].cards[0].0.isEmpty)
        XCTAssertFalse(session.projects[0].cards[1].0.isEmpty)
        XCTAssertFalse(session.projects[0].cards[2].0.isEmpty)
    }
    
    func testAddTodo() {
        session.add(.todo)
        XCTAssertEqual(2, session.projects[0].cards.count)
        XCTAssertFalse(session.projects[0].name.isEmpty)
        XCTAssertTrue(session.projects[0].cards[0].0.isEmpty)
        XCTAssertTrue(session.projects[0].cards[1].0.isEmpty)
    }
    
    func testAddShopping() {
        session.add(.shopping)
        XCTAssertEqual(2, session.projects[0].cards.count)
        XCTAssertFalse(session.projects[0].name.isEmpty)
        XCTAssertTrue(session.projects[0].cards[0].0.isEmpty)
        XCTAssertTrue(session.projects[0].cards[1].0.isEmpty)
    }
    
    func testDelete() {
        let expectSession = expectation(description: "")
        let expectProject = expectation(description: "")
        let time = Date()
        session.projects = [.init()]
        session.projects[0].mode = .kanban
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.session = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertEqual(.off, $0.projects[0].mode)
            expectSession.fulfill()
        }
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.time)
            XCTAssertEqual(.off, $0.mode)
            expectProject.fulfill()
        }
        session.delete(0)
        waitForExpectations(timeout: 1)
    }
}
