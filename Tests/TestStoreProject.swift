@testable import holbox
import XCTest

final class TestStoreProject: XCTestCase {
    private var store: Store!
    private var shared: StubShared!
    private var coder: Coder!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project2"))
        coder = .init()
        shared = .init()
        store = .init()
        store.shared = shared
        store.time = 0
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project2"))
    }
    
    func testSharedNotLocal() {
        let expect = expectation(description: "")
        store.prepare()
        let saved = Session()
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        var project = Project()
        project.mode = .kanban
        saved.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(saved).write(to: shared.url["session"]!)
        try! coder.project(project).write(to: shared.url["99"]!)
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertNotNil(session.items[99])
            XCTAssertEqual(.off, session.items[99]?.mode)
            XCTAssertNotNil($0.items[99])
            XCTAssertEqual(.kanban, $0.items[99]?.mode)
            XCTAssertEqual(.kanban, stored.mode)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedMultipleNotLocal() {
        let expect = expectation(description: "")
        store.prepare()
        let saved = Session()
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        var projectA = Project()
        projectA.name = "hello"
        projectA.mode = .kanban
        var projectB = Project()
        projectB.name = "world"
        projectB.mode = .kanban
        saved.items = [99: projectA, 101: projectB]
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        shared.url["101"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project2")
        try! coder.global(saved).write(to: shared.url["session"]!)
        try! coder.project(projectA).write(to: shared.url["99"]!)
        try! coder.project(projectB).write(to: shared.url["101"]!)
        store.loadSession {
            XCTAssertNotNil(try? self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99"))))
            XCTAssertNotNil(try? self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("101"))))
            XCTAssertNotNil($0.items[99])
            XCTAssertNotNil($0.items[101])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedNotLocalFailed() {
        let expect = expectation(description: "")
        store.prepare()
        let saved = Session()
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        saved.items[99] = .init()
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(saved).write(to: shared.url["session"]!)
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertTrue(session.items.isEmpty)
            XCTAssertTrue($0.items.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedUpdate() {
        let expect = expectation(description: "")
        store.prepare()
        let saved = Session()
        var project = Project()
        project.mode = .kanban
        project.name = "lorem"
        project.time = .init(timeIntervalSince1970: 10)
        saved.items[99] = project
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: Store.url.appendingPathComponent("99"))
        project.time = .init(timeIntervalSince1970: 100)
        project.name = "ipsum"
        saved.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(saved).write(to: shared.url["session"]!)
        try! coder.project(project).write(to: shared.url["99"]!)
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertEqual(1, session.items.count)
            XCTAssertEqual(1, $0.items.count)
            XCTAssertNotNil(session.items[99])
            XCTAssertNotNil($0.items[99])
            XCTAssertEqual("ipsum", $0.items[99]?.name)
            XCTAssertEqual("ipsum", stored.name)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 100).timeIntervalSince1970), Int(session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 100).timeIntervalSince1970), Int($0.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 100).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedUpdateFail() {
        let expect = expectation(description: "")
        store.prepare()
        let saved = Session()
        var project = Project()
        project.mode = .kanban
        project.time = .init(timeIntervalSince1970: 10)
        project.name = "lorem"
        saved.items[99] = project
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: Store.url.appendingPathComponent("99"))
        project.time = .init(timeIntervalSince1970: 100)
        saved.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(saved).write(to: shared.url["session"]!)
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertEqual(1, session.items.count)
            XCTAssertEqual(1, $0.items.count)
            XCTAssertEqual(.kanban, $0.items[99]?.mode)
            XCTAssertEqual("lorem", $0.items[99]?.name)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int(session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int($0.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNotShared() {
        let expectGlobal = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        let saved = Session()
        var project = Project()
        project.mode = .kanban
        project.name = "lorem"
        project.time = .init(timeIntervalSince1970: 200)
        saved.items[99] = project
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: Store.url.appendingPathComponent("99"))
        saved.items = [:]
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(saved).write(to: shared.url["session"]!)
        shared.saved = {
            if $0["99"] != nil {
                let uploaded = try! self.coder.project(.init(contentsOf: $0["99"]!))
                XCTAssertEqual("lorem", uploaded.name)
                XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(uploaded.time.timeIntervalSince1970))
                expectProject.fulfill()
            } else if $0["session"] != nil {
                let global = try! self.coder.global(.init(contentsOf: $0["session"]!))
                XCTAssertEqual(1, global.count)
                XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(global.first?.1.timeIntervalSince1970 ?? 0))
                expectGlobal.fulfill()
            }
        }
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertNotNil(session.items[99])
            XCTAssertNotNil($0.items[99])
            XCTAssertEqual("lorem", $0.items[99]?.name)
            XCTAssertEqual("lorem", stored.name)
            XCTAssertEqual(.kanban, $0.items[99]?.mode)
            XCTAssertEqual(.kanban, stored.mode)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int($0.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNotSharedMultiple() {
        let expectProjects = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        let saved = Session()
        var projectA = Project()
        projectA.name = "lorem"
        var projectB = Project()
        projectB.name = "ipsum"
        saved.items = [99: projectA, 101: projectB]
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(projectA).write(to: Store.url.appendingPathComponent("99"))
        try! coder.project(projectB).write(to: Store.url.appendingPathComponent("101"))
        shared.saved = {
            if $0["99"] != nil && $0["101"] != nil {
                let a = try! self.coder.project(.init(contentsOf: $0["99"]!))
                let b = try! self.coder.project(.init(contentsOf: $0["101"]!))
                XCTAssertEqual("lorem", a.name)
                XCTAssertEqual("ipsum", b.name)
                expectProjects.fulfill()
            }
        }
        store.loadSession { _ in
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalUpdate() {
        let expectGlobal = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        let saved = Session()
        var project = Project()
        project.mode = .kanban
        project.name = "lorem"
        project.time = .init(timeIntervalSince1970: 200)
        saved.items[99] = project
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: Store.url.appendingPathComponent("99"))
        project.time = .init(timeIntervalSince1970: 50)
        project.name = "ipsum"
        saved.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(saved).write(to: shared.url["session"]!)
        shared.saved = {
            if $0["99"] != nil {
                let uploaded = try! self.coder.project(.init(contentsOf: $0["99"]!))
                XCTAssertEqual("lorem", uploaded.name)
                XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(uploaded.time.timeIntervalSince1970))
                expectProject.fulfill()
            } else if $0["session"] != nil {
                let global = try! self.coder.global(.init(contentsOf: $0["session"]!))
                XCTAssertEqual(1, global.count)
                XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(global.first?.1.timeIntervalSince1970 ?? 0))
                expectGlobal.fulfill()
            }
        }
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertNotNil(session.items[99])
            XCTAssertNotNil($0.items[99])
            XCTAssertEqual("lorem", $0.items[99]?.name)
            XCTAssertEqual("lorem", stored.name)
            XCTAssertEqual(.kanban, $0.items[99]?.mode)
            XCTAssertEqual(.kanban, stored.mode)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int($0.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNoSharedYesProject() {
        let expectLoad = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        let session = Session()
        session.items[0] = .init()
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["0"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(session).write(to: shared.url["session"]!)
        try! coder.project(session.items[0]!).write(to: shared.url["0"]!)
        shared.load = {
            if $0.first == "session" {
                expectLoad.fulfill()
            } else if $0.first == "0" {
                expectProject.fulfill()
            }
        }
        store.loadSession {
            XCTAssertFalse($0.items.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNoSharedYesProjectFails() {
        let expectLoad = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        let session = Session()
        session.items[0] = .init()
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
        shared.load = {
            if $0.first == "session" {
                expectLoad.fulfill()
            } else if $0.first == "0" {
                expectProject.fulfill()
            }
        }
        store.loadSession {
            XCTAssertTrue($0.items.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNotSharedFails() {
        let expect = expectation(description: "")
        store.prepare()
        let saved = Session()
        var project = Project()
        project.mode = .kanban
        project.name = "lorem"
        saved.items[33] = project
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: Store.url.appendingPathComponent("33"))
        store.loadSession {
            XCTAssertNotNil($0.items[33])
            XCTAssertEqual("lorem", $0.items[33]?.name)
            XCTAssertEqual(.kanban, $0.items[33]?.mode)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
