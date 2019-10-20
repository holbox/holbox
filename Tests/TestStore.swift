@testable import holbox
import XCTest

final class TestStore: XCTestCase {
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
        store.prepare()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
    }
    
    func testLoad() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.store.load { _ in
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveSession() {
        let expectShare = expectation(description: "")
        let expectSave = expectation(description: "")
        let expectFinish = expectation(description: "")
        Store.id = "hello"
        shared.save = {
            XCTAssertNotNil(try? self.coder.global(.init(contentsOf: $0["hello"]!)))
            expectShare.fulfill()
        }
        store.save(Session()) {
            XCTAssertNotNil(try? self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session"))))
            expectSave.fulfill()
        }
        store.share(Session()) {
            expectFinish.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveSessionNotSharing() {
        let expect = expectation(description: "")
        Store.id = "hello"
        shared.save = { _ in XCTFail() }
        store.save(Session()) {
            XCTAssertNotNil(try? self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session"))))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveProject() {
        let expectShare = expectation(description: "")
        let expectSave = expectation(description: "")
        Store.id = "hello"
        shared.save = {
            XCTAssertNotNil(try? self.coder.project(.init(contentsOf: $0["hello56"]!)))
            expectShare.fulfill()
        }
        var project = Project()
        project.id = 56
        store.save(project) {
            XCTAssertNotNil(try? self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("56"))))
            expectSave.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
