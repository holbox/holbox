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
        session.projects[0] = .init()
        session.projects[0]!.mode = .kanban
        XCTAssertEqual(0, session.available)
        XCTAssertEqual(1, session.capacity)
        session.projects[0]!.mode = .off
        XCTAssertEqual(1, session.available)
        XCTAssertEqual(1, session.capacity)
        session.projects = [0: .init(), 1: .init()]
        session.projects[0]!.mode = .kanban
        session.projects[1]!.mode = .kanban
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
        XCTAssertEqual(0, session.add(.kanban))
        XCTAssertEqual(.kanban, session.projects[0]?.mode)
        XCTAssertNotNil(session.projects[0])
    }
    
    func testAddSecond() {
        var project = Project()
        project.mode = .todo
        session.projects[0] = project
        XCTAssertEqual(1, session.add(.kanban))
        XCTAssertNotNil(session.projects[1])
    }
    
    func testAddLowerId() {
        var project = Project()
        project.mode = .todo
        session.projects = [5: project]
        XCTAssertEqual(0, session.add(.kanban))
        XCTAssertNotNil(session.projects[0])
    }
    
    func testAddIntersectedId() {
        var projectA = Project()
        projectA.mode = .todo
        var projectB = Project()
        projectB.mode = .todo
        session.projects = [3: projectA, 0: projectB]
        XCTAssertEqual(1, session.add(.kanban))
        XCTAssertNotNil(session.projects[1])
    }
    
    func testAddDeadId() {
        var projectA = Project()
        projectA.mode = .todo
        var projectB = Project()
        projectB.name = "old one"
        var projectC = Project()
        projectC.mode = .todo
        session.projects = [0: projectA, 1: projectB, 2: projectC]
        XCTAssertEqual(1, session.add(.kanban))
        XCTAssertNotNil(session.projects[1])
        XCTAssertEqual(3, session.projects.count)
        session.projects.forEach {
            XCTAssertNotEqual("old one", $0.1.name)
        }
    }
    
    func testAddSaves() {
        let expect = expectation(description: "")
        var project = Project()
        project.mode = .todo
        session.projects[0] = project
        store.project = {
            XCTAssertEqual(1, $0.projects(.kanban).count)
            XCTAssertEqual(0, $0.projects(.kanban).first)
            XCTAssertNotNil($0.projects[1])
            XCTAssertEqual(2, $0.projects.count)
            XCTAssertEqual(.kanban, $0.projects[1]?.mode)
            XCTAssertEqual(1, $1)
            XCTAssertEqual(.kanban, $2.mode)
            expect.fulfill()
        }
        XCTAssertEqual(1, session.add(.kanban))
        waitForExpectations(timeout: 1)
    }
    
    func testAddKanban() {
        _ = session.add(.kanban)
        XCTAssertEqual(3, session.projects[0]!.cards.count)
        XCTAssertFalse(session.projects[0]!.name.isEmpty)
        XCTAssertFalse(session.projects[0]!.cards[0].0.isEmpty)
        XCTAssertFalse(session.projects[0]!.cards[1].0.isEmpty)
        XCTAssertFalse(session.projects[0]!.cards[2].0.isEmpty)
    }
    
    func testAddTodo() {
        _ = session.add(.todo)
        XCTAssertEqual(2, session.projects[0]!.cards.count)
        XCTAssertFalse(session.projects[0]!.name.isEmpty)
        XCTAssertTrue(session.projects[0]!.cards[0].0.isEmpty)
        XCTAssertTrue(session.projects[0]!.cards[1].0.isEmpty)
    }
    
    func testAddShopping() {
        _ = session.add(.shopping)
        XCTAssertEqual(2, session.projects[0]!.cards.count)
        XCTAssertFalse(session.projects[0]!.name.isEmpty)
        XCTAssertTrue(session.projects[0]!.cards[0].0.isEmpty)
        XCTAssertTrue(session.projects[0]!.cards[1].0.isEmpty)
    }
    
    func testDelete() {
        let expect = expectation(description: "")
        let time = Date()
        session.projects[0] = .init()
        session.projects[0]!.mode = .kanban
        session.projects[0]!.time = .init(timeIntervalSince1970: 0)
        store.project = {
            XCTAssertLessThanOrEqual(time, $0.projects[0]!.time)
            XCTAssertEqual(.off, $0.projects[0]!.mode)
            XCTAssertLessThanOrEqual(time, $2.time)
            XCTAssertEqual(.off, $2.mode)
            expect.fulfill()
        }
        session.delete(0)
        waitForExpectations(timeout: 1)
    }
    
    func testOnlyActive() {
        var project0 = Project()
        var project1 = Project()
        var project2 = Project()
        project1.mode = .kanban
        project0.name = "b"
        project1.name = "c"
        project2.name = "a"
        session.projects = [0: project0, 1: project1, 2: project2]
//        XCTAssertEqual(session.projects().count, <#T##expression2: Equatable##Equatable#>)
    }
    
    func testSorted() {
        var project0 = Project()
        var project1 = Project()
        var project2 = Project()
        project0.mode = .kanban
        project1.mode = .kanban
        project2.mode = .kanban
        project0.name = "b"
        project1.name = "c"
        project2.name = "a"
        session.projects = [0: project0, 1: project1, 2: project2]
//        XCTAssertEqual(2, session.projects(.kanban)[0])
//        XCTAssertEqual(0, session.projects(.kanban)[1])
//        XCTAssertEqual(1, session.projects(.kanban)[2])
    }
}
