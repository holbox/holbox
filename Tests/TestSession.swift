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
        XCTAssertGreaterThanOrEqual(Calendar.current.date(byAdding: .day, value: 1, to: .init())!, session.rating)
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
    
    func testAddFirst() {
        session.add(.kanban)
        XCTAssertEqual(.kanban, session.projects[0].mode)
        XCTAssertEqual(0, session.projects[0].id)
    }
    
    func testAddSecond() {
        var project = Project()
        project.mode = .todo
        session.projects = [project]
        session.add(.kanban)
        XCTAssertEqual(1, session.projects[0].id)
    }
    
    func testAddLowerId() {
        var project = Project()
        project.mode = .todo
        project.id = 5
        session.projects = [project]
        session.add(.kanban)
        XCTAssertEqual(0, session.projects[0].id)
    }
    
    func testAddIntersectedId() {
        var projectA = Project()
        projectA.mode = .todo
        projectA.id = 3
        var projectB = Project()
        projectB.mode = .todo
        projectB.id = 0
        session.projects = [projectA, projectB]
        session.add(.kanban)
        XCTAssertEqual(1, session.projects[0].id)
    }
    
    func testAddDeadId() {
        var projectA = Project()
        projectA.id = 0
        projectA.mode = .todo
        var projectB = Project()
        projectB.name = "old one"
        projectB.id = 1
        var projectC = Project()
        projectC.id = 2
        projectC.mode = .todo
        session.projects = [projectA, projectB, projectC]
        session.add(.kanban)
        XCTAssertEqual(1, session.projects[0].id)
        XCTAssertEqual(3, session.projects.count)
        session.projects.forEach {
            XCTAssertNotEqual("old one", $0.name)
        }
    }
    
    func testAddSaves() {
        let expect = expectation(description: "")
        var project = Project()
        project.mode = .todo
        session.projects = [project]
        store.project = {
            XCTAssertEqual(1, $0.projects(.kanban).count)
            XCTAssertEqual(0, $0.projects(.kanban).first)
            XCTAssertEqual(1, $0.projects.first?.id)
            XCTAssertEqual(2, $0.projects.count)
            XCTAssertEqual(.kanban, $0.projects.first?.mode)
            XCTAssertEqual(1, $1.id)
            expect.fulfill()
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
        let expect = expectation(description: "")
        let time = Date()
        session.projects = [.init()]
        session.projects[0].mode = .kanban
        session.projects[0].time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0].time)
            XCTAssertEqual(.off, $0.projects[0].mode)
            XCTAssertLessThanOrEqual(time, $1.time)
            XCTAssertEqual(.off, $1.mode)
            expect.fulfill()
        }
        session.delete(0)
        waitForExpectations(timeout: 1)
    }
    
    func testSorted() {
        var project0 = Project()
        var project1 = Project()
        var project2 = Project()
        project1.id = 1
        project2.id = 2
        project0.mode = .kanban
        project1.mode = .kanban
        project2.mode = .kanban
        project0.name = "b"
        project1.name = "c"
        project2.name = "a"
        session.projects = [project0, project1, project2]
        XCTAssertEqual(2, session.projects(.kanban)[0])
        XCTAssertEqual(0, session.projects(.kanban)[1])
        XCTAssertEqual(1, session.projects(.kanban)[2])
    }
}
