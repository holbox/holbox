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
            let share = try! Coder().shared(Data(contentsOf: $1))
            XCTAssertTrue(share.1.isEmpty)
            expectSave.fulfill()
        }
        store.loadSession {
            let session = try! Coder().session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(Int(session.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertTrue(session.projects.isEmpty)
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
        saved.counter = 55
        try! Coder().session(saved).write(to: Store.url.appendingPathComponent("session"))
        shared.load = {
            XCTAssertEqual("hello world", $0)
            expectLoad.fulfill()
        }
        shared.save = {
            XCTAssertEqual("hello world", $0)
            let share = try! Coder().shared(Data(contentsOf: $1))
            XCTAssertEqual(55, share.0)
            expectSave.fulfill()
        }
        store.loadSession {
            let session = try! Coder().session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(Int(session.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(Int(saved.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(session.counter, $0.counter)
            XCTAssertEqual(saved.counter, $0.counter)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoadSessionLocalNoSharedYes() {
        let expectLoad = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let session = Session()
        session.counter = 55
        shared.url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! Coder().shared(session).write(to: shared.url!)
        shared.load = {
            XCTAssertEqual("hello world", $0)
            expectLoad.fulfill()
        }
        store.loadSession {
            let loaded = try! Coder().session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(loaded.counter, $0.counter)
            XCTAssertEqual(session.counter, $0.counter)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoadSessionLocalAndSharedSynched() {
        let expectLoad = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        saved.rating = Date(timeIntervalSince1970: 10)
        saved.counter = 55
        try! Coder().session(saved).write(to: Store.url.appendingPathComponent("session"))
        shared.url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! Coder().shared(saved).write(to: shared.url!)
        shared.load = {
            XCTAssertEqual("hello world", $0)
            expectLoad.fulfill()
        }
        store.loadSession {
            XCTAssertEqual(Int(saved.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(saved.counter, $0.counter)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoadSessionSharedBiggerCounter() {
        let expect = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        saved.rating = Date(timeIntervalSince1970: 10)
        saved.counter = 55
        try! Coder().session(saved).write(to: Store.url.appendingPathComponent("session"))
        saved.counter = 88
        shared.url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! Coder().shared(saved).write(to: shared.url!)
        store.loadSession {
            let session = try! Coder().session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(88, session.counter)
            XCTAssertEqual(88, $0.counter)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLoadSessionLocalBiggerCounter() {
        let expectSave = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        saved.rating = Date(timeIntervalSince1970: 10)
        saved.counter = 33
        try! Coder().session(saved).write(to: Store.url.appendingPathComponent("session"))
        saved.counter = 11
        shared.url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! Coder().shared(saved).write(to: shared.url!)
        shared.save = {
            XCTAssertEqual("hello world", $0)
            let share = try! Coder().shared(Data(contentsOf: $1))
            XCTAssertEqual(33, share.0)
            expectSave.fulfill()
        }
        store.loadSession {
            let session = try! Coder().session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(33, session.counter)
            XCTAssertEqual(33, $0.counter)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
