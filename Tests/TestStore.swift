@testable import holbox
import XCTest

final class TestStore: XCTestCase {
    private var store: Store!
    private var ubi: StubUbi!
    private var shared: StubShared!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp"))
        ubi = .init()
        shared = .init()
        store = .init()
        store.ubi = ubi
        store.shared = shared
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp"))
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
        let expectLoad = expectation(description: "")
        let expectSave = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        shared.load = {
            XCTAssertEqual("hello world", $0)
            expectLoad.fulfill()
        }
        shared.save = {
            XCTAssertEqual("hello world", $0)
            let global = try! Coder().global(Data(contentsOf: $1))
            XCTAssertTrue(global.projects.isEmpty)
            expectSave.fulfill()
        }
        store.loadSession {
            let session = try! Coder().session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(Int(session.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertTrue(session.global.projects.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoadSessionLocalYesSharedNo() {
        let expectLoad = expectation(description: "")
        let expectSave = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        saved.rating = Date(timeIntervalSince1970: 10)
        saved.global.counter = 55
        try! Coder().code(saved).write(to: Store.url.appendingPathComponent("session"))
        shared.load = {
            XCTAssertEqual("hello world", $0)
            expectLoad.fulfill()
        }
        shared.save = {
            XCTAssertEqual("hello world", $0)
            let global = try! Coder().global(Data(contentsOf: $1))
            XCTAssertEqual(saved.global.counter , global.counter)
            expectSave.fulfill()
        }
        store.loadSession {
            let session = try! Coder().session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(Int(session.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(Int(saved.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(session.global.counter , $0.global.counter)
            XCTAssertEqual(saved.global.counter , $0.global.counter)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoadSessionLocalNoSharedYes() {
        let expectLoad = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        var global = Session.Global()
        global.counter = 55
        shared.url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! Coder().code(global).write(to: shared.url!)
        shared.load = {
            XCTAssertEqual("hello world", $0)
            expectLoad.fulfill()
        }
        store.loadSession {
            let session = try! Coder().session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(session.global.counter , $0.global.counter)
            XCTAssertEqual(global.counter , $0.global.counter)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
