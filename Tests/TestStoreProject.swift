@testable import holbox
import XCTest

final class TestStoreProject: XCTestCase {
    private var store: Store!
    private var shared: StubShared!
    private var coder: Coder!
    private var session: Session!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project2"))
        coder = .init()
        shared = .init()
        store = .init()
        session = .init()
        try? FileManager.default.removeItem(at: store.url)
        store.shared = shared
        store.time = 0
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project2"))
    }
    
    func testSharedNotLocal() {
        let expect = expectation(description: "")
        store.prepare()
        try! coder.session(session).write(to: store.url.appendingPathComponent("session"))
        var project = Project()
        project.mode = .kanban
        session.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(session).write(to: shared.url["session"]!)
        try! coder.project(project).write(to: shared.url["99"]!)
        store.load(session: session) {
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(.init(contentsOf: self.store.url.appendingPathComponent("99")))
            XCTAssertNotNil(session.items[99])
            XCTAssertEqual(.off, session.items[99]?.mode)
            XCTAssertNotNil(self.session.items[99])
            XCTAssertEqual(.kanban, self.session.items[99]?.mode)
            XCTAssertEqual(.kanban, stored.mode)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedMultipleNotLocal() {
        let expect = expectation(description: "")
        store.prepare()
        try! coder.session(session).write(to: store.url.appendingPathComponent("session"))
        var projectA = Project()
        projectA.name = "hello"
        projectA.mode = .kanban
        var projectB = Project()
        projectB.name = "world"
        projectB.mode = .kanban
        session.items = [99: projectA, 101: projectB]
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        shared.url["101"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project2")
        try! coder.global(session).write(to: shared.url["session"]!)
        try! coder.project(projectA).write(to: shared.url["99"]!)
        try! coder.project(projectB).write(to: shared.url["101"]!)
        store.load(session: session) {
            XCTAssertNotNil(try? self.coder.project(.init(contentsOf: self.store.url.appendingPathComponent("99"))))
            XCTAssertNotNil(try? self.coder.project(.init(contentsOf: self.store.url.appendingPathComponent("101"))))
            XCTAssertNotNil(self.session.items[99])
            XCTAssertNotNil(self.session.items[101])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedNotLocalFailed() {
        let expect = expectation(description: "")
        store.prepare()
        try! coder.session(session).write(to: store.url.appendingPathComponent("session"))
        session.items[99] = .init()
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
        store.load(session: session) {
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session")))
            XCTAssertTrue(session.items.isEmpty)
            XCTAssertTrue(self.session.items.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedUpdate() {
        let expect = expectation(description: "")
        store.prepare()
        var project = Project()
        project.mode = .kanban
        project.name = "lorem"
        project.time = .init(timeIntervalSince1970: 10)
        session.items[99] = project
        try! coder.session(session).write(to: store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: store.url.appendingPathComponent("99"))
        project.time = .init(timeIntervalSince1970: 100)
        project.name = "ipsum"
        session.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(session).write(to: shared.url["session"]!)
        try! coder.project(project).write(to: shared.url["99"]!)
        store.load(session: session) {
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(.init(contentsOf: self.store.url.appendingPathComponent("99")))
            XCTAssertEqual(1, session.items.count)
            XCTAssertEqual(1, self.session.items.count)
            XCTAssertNotNil(session.items[99])
            XCTAssertNotNil(self.session.items[99])
            XCTAssertEqual("ipsum", self.session.items[99]?.name)
            XCTAssertEqual("ipsum", stored.name)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 100).timeIntervalSince1970), Int(session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 100).timeIntervalSince1970), Int(self.session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 100).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedUpdateFail() {
        let expect = expectation(description: "")
        store.prepare()
        var project = Project()
        project.mode = .kanban
        project.time = .init(timeIntervalSince1970: 10)
        project.name = "lorem"
        session.items[99] = project
        try! coder.session(session).write(to: store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: store.url.appendingPathComponent("99"))
        project.time = .init(timeIntervalSince1970: 100)
        session.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
        store.load(session: session) {
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(.init(contentsOf: self.store.url.appendingPathComponent("99")))
            XCTAssertEqual(1, session.items.count)
            XCTAssertEqual(1, self.session.items.count)
            XCTAssertEqual(.kanban, self.session.items[99]?.mode)
            XCTAssertEqual("lorem", self.session.items[99]?.name)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int(session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int(self.session.items[99]?.time.timeIntervalSince1970 ?? 0))
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
        var project = Project()
        project.mode = .kanban
        project.name = "lorem"
        project.time = .init(timeIntervalSince1970: 200)
        session.items[99] = project
        try! coder.session(session).write(to: store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: store.url.appendingPathComponent("99"))
        session.items = [:]
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
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
        store.load(session: session) {
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(.init(contentsOf: self.store.url.appendingPathComponent("99")))
            XCTAssertNotNil(session.items[99])
            XCTAssertNotNil(self.session.items[99])
            XCTAssertEqual("lorem", self.session.items[99]?.name)
            XCTAssertEqual("lorem", stored.name)
            XCTAssertEqual(.kanban, self.session.items[99]?.mode)
            XCTAssertEqual(.kanban, stored.mode)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(self.session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNotSharedMultiple() {
        let expectProjects = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        var projectA = Project()
        projectA.name = "lorem"
        var projectB = Project()
        projectB.name = "ipsum"
        session.items = [99: projectA, 101: projectB]
        try! coder.session(session).write(to: store.url.appendingPathComponent("session"))
        try! coder.project(projectA).write(to: store.url.appendingPathComponent("99"))
        try! coder.project(projectB).write(to: store.url.appendingPathComponent("101"))
        shared.saved = {
            if $0["99"] != nil && $0["101"] != nil {
                let a = try! self.coder.project(.init(contentsOf: $0["99"]!))
                let b = try! self.coder.project(.init(contentsOf: $0["101"]!))
                XCTAssertEqual("lorem", a.name)
                XCTAssertEqual("ipsum", b.name)
                expectProjects.fulfill()
            }
        }
        store.load(session: session) {
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalUpdate() {
        let expectGlobal = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        var project = Project()
        project.mode = .kanban
        project.name = "lorem"
        project.time = .init(timeIntervalSince1970: 200)
        session.items[99] = project
        try! coder.session(session).write(to: store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: store.url.appendingPathComponent("99"))
        project.time = .init(timeIntervalSince1970: 50)
        project.name = "ipsum"
        session.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
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
        store.load(session: session) {
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(.init(contentsOf: self.store.url.appendingPathComponent("99")))
            XCTAssertNotNil(session.items[99])
            XCTAssertNotNil(self.session.items[99])
            XCTAssertEqual("lorem", self.session.items[99]?.name)
            XCTAssertEqual("lorem", stored.name)
            XCTAssertEqual(.kanban, self.session.items[99]?.mode)
            XCTAssertEqual(.kanban, stored.mode)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(session.items[99]?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(self.session.items[99]?.time.timeIntervalSince1970 ?? 0))
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
        store.load(session: session) {
            XCTAssertFalse(self.session.items.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNoSharedYesProjectFails() {
        let expectLoad = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        session.items[0] = .init()
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
        session.items = [:]
        shared.load = {
            if $0.first == "session" {
                expectLoad.fulfill()
            } else if $0.first == "0" {
                expectProject.fulfill()
            }
        }
        store.load(session: session) {
            XCTAssertTrue(self.session.items.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNotSharedFails() {
        let expect = expectation(description: "")
        store.prepare()
        var project = Project()
        project.mode = .kanban
        project.name = "lorem"
        session.items[33] = project
        try! coder.session(session).write(to: store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: store.url.appendingPathComponent("33"))
        store.load(session: session) {
            XCTAssertNotNil(self.session.items[33])
            XCTAssertEqual("lorem", self.session.items[33]?.name)
            XCTAssertEqual(.kanban, self.session.items[33]?.mode)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
