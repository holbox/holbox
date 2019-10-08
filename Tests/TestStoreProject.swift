@testable import holbox
import XCTest

final class TestStoreProject: XCTestCase {
    private var store: Store!
    private var ubi: StubUbi!
    private var shared: StubShared!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
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
    
    func testSharedProjectNotLocal() {
        let expect = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        try! Coder().session(saved).write(to: Store.url.appendingPathComponent("session"))
        var project = Project()
        project.id = 99
        project.mode = .kanban
        saved.projects = [project]
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["hello world.99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! Coder().global(saved).write(to: shared.url["hello world"]!)
        try! Coder().project(project).write(to: shared.url["hello world.99"]!)
        store.loadSession {
            let session = try! Coder().session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            let stored = try! Coder().project(Data(contentsOf: Store.url.appendingPathComponent("99")))
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
}
