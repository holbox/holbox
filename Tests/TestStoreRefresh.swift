@testable import holbox
import XCTest

final class TestStoreRefresh: XCTestCase {
    private var store: Store!
    private var shared: StubShared!
    private var coder: Coder!
    private var session: Session!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
        coder = .init()
        shared = .init()
        session = .init()
        store = .init()
        store.shared = shared
        store.prepare()
        session.store = store
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
    }
    
    func testRefresh() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.session.refresh {
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRefreshable() {
        XCTAssertFalse(session.refreshable)
        session.refreshed = 0
        XCTAssertTrue(session.refreshable)
    }
    
    func testRefreshInterval() {
        let expectStore = expectation(description: "")
        let expectAll = expectation(description: "")
        let store = StubStore()
        session.refreshed = 0
        store.refresh = { _ in
            expectStore.fulfill()
        }
        self.session.store = store
        self.session.refresh {
            DispatchQueue.global(qos: .background).async {
                self.session.refresh {
                    expectAll.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNoSession() {
        let expect = expectation(description: "")
        store.refresh(session) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNoProjects() {
        let expect = expectation(description: "")
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
        store.refresh(session) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNothingNew() {
        let expect = expectation(description: "")
        session.projects = [.init()]
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
        shared.load = {
            $0.forEach {
                XCTAssertEqual("session", $0)
            }
        }
        store.refresh(session) {
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDownloadFailed() {
            let expect = expectation(description: "")
            let online = Session()
            var project = Project()
            project.id = 99
            project.mode = .kanban
            online.projects = [project]
            shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
            try! coder.global(online).write(to: shared.url["session"]!)
            store.refresh(session) {
                expect.fulfill()
            }
            waitForExpectations(timeout: 1)
        }
    
    func testDownload() {
        let expect = expectation(description: "")
        let online = Session()
        var project = Project()
        project.id = 99
        project.mode = .kanban
        online.projects = [project]
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(online).write(to: shared.url["session"]!)
        try! coder.project(project).write(to: shared.url["99"]!)
        store.refresh(session) {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("99")))
            XCTAssertEqual(99, session.projects.first?.id)
            XCTAssertEqual(.off, session.projects.first?.mode)
            XCTAssertEqual(99, self.session.projects.first?.id)
            XCTAssertEqual(.kanban, self.session.projects.first?.mode)
            XCTAssertEqual(0, stored.id)
            XCTAssertEqual(.kanban, stored.mode)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdate() {
        let expect = expectation(description: "")
        var project = Project()
        project.name = "lorem"
        session.projects = [project]
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["0"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(session).write(to: shared.url["session"]!)
        try! coder.project(project).write(to: shared.url["0"]!)
        session.projects[0].time = .init(timeIntervalSince1970: 10)
        session.projects[0].name = "ipsum"
        store.refresh(session) {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("0")))
            XCTAssertEqual("lorem", self.session.projects.first?.name)
            XCTAssertEqual("lorem", stored.name)
            XCTAssertEqual(1, session.projects.count)
            XCTAssertEqual(1, self.session.projects.count)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
