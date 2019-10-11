@testable import holbox
import XCTest

final class TestStoreProject: XCTestCase {
    private var store: Store!
    private var ubi: StubUbi!
    private var shared: StubShared!
    private var coder: Coder!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
        coder = .init()
        ubi = .init()
        shared = .init()
        store = .init()
        store.ubi = ubi
        store.shared = shared
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
    }
    
    func testSharedNotLocal() {
        let expect = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        var project = Project()
        project.id = 99
        project.mode = .kanban
        saved.projects = [project]
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["hello world99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(saved).write(to: shared.url["hello world"]!)
        try! coder.project(project).write(to: shared.url["hello world99"]!)
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertEqual(99, session.projects.first?.id)
            XCTAssertEqual(.off, session.projects.first?.mode)
            XCTAssertEqual(99, $0.projects.first?.id)
            XCTAssertEqual(.kanban, $0.projects.first?.mode)
            XCTAssertEqual(0, stored.id)
            XCTAssertEqual(.kanban, stored.mode)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedNotLocalFailed() {
        let expect = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        var project = Project()
        project.id = 99
        saved.projects = [project]
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(saved).write(to: shared.url["hello world"]!)
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertTrue(session.projects.isEmpty)
            XCTAssertTrue($0.projects.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedUpdate() {
        let expect = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        var project = Project()
        project.id = 99
        project.mode = .kanban
        project.name = "lorem"
        project.time = .init(timeIntervalSince1970: 10)
        saved.projects = [project]
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: Store.url.appendingPathComponent("99"))
        project.time = .init(timeIntervalSince1970: 100)
        project.name = "ipsum"
        saved.projects = [project]
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["hello world99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(saved).write(to: shared.url["hello world"]!)
        try! coder.project(project).write(to: shared.url["hello world99"]!)
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertEqual(1, session.projects.count)
            XCTAssertEqual(1, $0.projects.count)
            XCTAssertEqual(99, session.projects.first?.id)
            XCTAssertEqual(99, $0.projects.first?.id)
            XCTAssertEqual("ipsum", $0.projects.first?.name)
            XCTAssertEqual("ipsum", stored.name)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 100).timeIntervalSince1970), Int(session.projects.first?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 100).timeIntervalSince1970), Int($0.projects.first?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 100).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedUpdateFail() {
        let expect = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        var project = Project()
        project.id = 99
        project.mode = .kanban
        project.time = .init(timeIntervalSince1970: 10)
        project.name = "lorem"
        saved.projects = [project]
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: Store.url.appendingPathComponent("99"))
        project.time = .init(timeIntervalSince1970: 100)
        saved.projects = [project]
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(saved).write(to: shared.url["hello world"]!)
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertEqual(1, session.projects.count)
            XCTAssertEqual(1, $0.projects.count)
            XCTAssertEqual(.kanban, $0.projects.first?.mode)
            XCTAssertEqual("lorem", $0.projects.first?.name)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int(session.projects.first?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int($0.projects.first?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNotShared() {
        let expectGlobal = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        var project = Project()
        project.id = 99
        project.mode = .kanban
        project.name = "lorem"
        project.time = .init(timeIntervalSince1970: 200)
        saved.projects = [project]
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: Store.url.appendingPathComponent("99"))
        saved.projects = []
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(saved).write(to: shared.url["hello world"]!)
        shared.save = {
            if $0 == "hello world99" {
                let uploaded = try! self.coder.project(.init(contentsOf: $1))
                XCTAssertEqual("lorem", uploaded.name)
                XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(uploaded.time.timeIntervalSince1970))
                expectProject.fulfill()
            } else if $0 == "hello world" {
                let global = try! self.coder.global(.init(contentsOf: $1))
                XCTAssertEqual(1, global.1.count)
                XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(global.1.first?.1.timeIntervalSince1970 ?? 0))
                expectGlobal.fulfill()
            }
        }
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertEqual(99, session.projects.first?.id)
            XCTAssertEqual(99, $0.projects.first?.id)
            XCTAssertEqual("lorem", $0.projects.first?.name)
            XCTAssertEqual("lorem", stored.name)
            XCTAssertEqual(.kanban, $0.projects.first?.mode)
            XCTAssertEqual(.kanban, stored.mode)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(session.projects.first?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int($0.projects.first?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalUpdate() {
        let expectGlobal = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        var project = Project()
        project.id = 99
        project.mode = .kanban
        project.name = "lorem"
        project.time = .init(timeIntervalSince1970: 200)
        saved.projects = [project]
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        try! coder.project(project).write(to: Store.url.appendingPathComponent("99"))
        project.time = .init(timeIntervalSince1970: 50)
        project.name = "ipsum"
        saved.projects = [project]
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(saved).write(to: shared.url["hello world"]!)
        shared.save = {
            if $0 == "hello world99" {
                let uploaded = try! self.coder.project(.init(contentsOf: $1))
                XCTAssertEqual("lorem", uploaded.name)
                XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(uploaded.time.timeIntervalSince1970))
                expectProject.fulfill()
            } else if $0 == "hello world" {
                let global = try! self.coder.global(.init(contentsOf: $1))
                XCTAssertEqual(1, global.1.count)
                XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(global.1.first?.1.timeIntervalSince1970 ?? 0))
                expectGlobal.fulfill()
            }
        }
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertEqual(99, session.projects.first?.id)
            XCTAssertEqual(99, $0.projects.first?.id)
            XCTAssertEqual("lorem", $0.projects.first?.name)
            XCTAssertEqual("lorem", stored.name)
            XCTAssertEqual(.kanban, $0.projects.first?.mode)
            XCTAssertEqual(.kanban, stored.mode)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(session.projects.first?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int($0.projects.first?.time.timeIntervalSince1970 ?? 0))
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 200).timeIntervalSince1970), Int(stored.time.timeIntervalSince1970))
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNoSharedYesProject() {
        let expectLoad = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let session = Session()
        session.projects = [.init()]
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["hello world0"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(session).write(to: shared.url["hello world"]!)
        try! coder.project(session.projects.first!).write(to: shared.url["hello world0"]!)
        shared.load = {
            if $0 == "hello world" {
                expectLoad.fulfill()
            } else if $0 == "hello world0" {
                expectProject.fulfill()
            }
        }
        store.loadSession {
            XCTAssertFalse($0.projects.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNoSharedYesProjectFails() {
        let expectLoad = expectation(description: "")
        let expectProject = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let session = Session()
        session.projects = [.init()]
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["hello world"]!)
        shared.load = {
            if $0 == "hello world" {
                expectLoad.fulfill()
            } else if $0 == "hello world0" {
                expectProject.fulfill()
            }
        }
        store.loadSession {
            XCTAssertTrue($0.projects.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
