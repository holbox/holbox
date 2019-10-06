@testable import holbox
import XCTest

final class TestStore: XCTestCase {
    private var store: Store!
    private var ubi: StubUbi!
    private var shared: StubShared!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Store.url)
        ubi = .init()
        shared = .init()
        store = .init()
        store.ubi = ubi
        store.shared = shared
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Store.url)
    }
    
    func testPrepare() {
        store.prepare()
        XCTAssertTrue(FileManager.default.fileExists(atPath: Store.url.path))
    }
    
    func testLoadIdFirstTime() {
        store.prepare()
        store.loadId()
        XCTAssertFalse(Store.id.isEmpty)
        XCTAssertEqual(ubi.string, Store.id)
        XCTAssertEqual(Store.id, try! String(decoding: Data(contentsOf: Store.url.appendingPathComponent("id")), as: UTF8.self))
    }
    
    func testLoadIdSecondTime() {
        store.prepare()
        try! Data("hello world".utf8).write(to: Store.url.appendingPathComponent("id"))
        store.loadId()
        XCTAssertEqual("hello world", Store.id)
    }
    
    func testLoadIdWithUbi() {
        ubi.string = "hello world"
        store.prepare()
        store.loadId()
        XCTAssertEqual("hello world", Store.id)
        XCTAssertEqual(Store.id, try! String(decoding: Data(contentsOf: Store.url.appendingPathComponent("id")), as: UTF8.self))
    }
    
    func testLoadSessionFirstTime() {
        let expect = expectation(description: "")
        store.prepare()
        store.loadSession { _ in
            
//            let session = try! JSONDecoder().decode(Session.self, from: Data(contentsOf: Store.url.appendingPathComponent("session")))
//            XCTAssertEqual(session.rating, $0.rating)
//            XCTAssertTrue(session.global.projects.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
