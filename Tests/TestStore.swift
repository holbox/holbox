@testable import holbox
import XCTest

final class TestStore: XCTestCase {
    private var store: Store!
    private var shared: StubShared!
    private var coder: Coder!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
        coder = .init()
        shared = .init()
        store = .init()
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
    
    func testSaveSessionNotSharing() {
        let expect = expectation(description: "")
        shared.saved = { _ in XCTFail() }
        store.save(Session())
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.01) {
            XCTAssertNotNil(try? self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session"))))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSaveProject() {
        let expect = expectation(description: "")
        shared.saved = {
            XCTAssertNotNil(try? self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session"))))
            XCTAssertNotNil(try? self.coder.project(Data(contentsOf: Store.url.appendingPathComponent("56"))))
            XCTAssertNotNil(try? self.coder.global(.init(contentsOf: $0["session"]!)))
            XCTAssertNotNil(try? self.coder.project(.init(contentsOf: $0["56"]!)))
            expect.fulfill()
        }
        var project = Project()
        project.id = 56
        store.save(Session(), project: project)
        waitForExpectations(timeout: 1)
    }
}
