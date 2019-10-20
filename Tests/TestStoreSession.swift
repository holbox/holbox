@testable import holbox
import XCTest

final class TestStoreSession: XCTestCase {
    private var store: Store!
    private var ubi: StubUbi!
    private var shared: StubShared!
    private var coder: Coder!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp"))
        coder = .init()
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
    
    func testFirstTime() {
        let expectLoad = expectation(description: "")
        let expectSave = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        shared.load = {
            XCTAssertEqual("hello world", $0.first)
            expectLoad.fulfill()
        }
        shared.save = {
            XCTAssertEqual("hello world", $0)
            let global = try! self.coder.global(Data(contentsOf: $1))
            XCTAssertTrue(global.1.isEmpty)
            expectSave.fulfill()
        }
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(Int(session.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertTrue(session.projects.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalYesSharedNo() {
        let expectLoad = expectation(description: "")
        let expectSave = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        saved.rating = Date(timeIntervalSince1970: 10)
        saved.counter = 55
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        shared.load = {
            XCTAssertEqual("hello world", $0.first)
            expectLoad.fulfill()
        }
        shared.save = {
            XCTAssertEqual("hello world", $0)
            let global = try! self.coder.global(Data(contentsOf: $1))
            XCTAssertEqual(55, global.0)
            expectSave.fulfill()
        }
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(Int(session.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(Int(saved.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(session.counter, $0.counter)
            XCTAssertEqual(saved.counter, $0.counter)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNoSharedYes() {
        let expectLoad = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let session = Session()
        session.counter = 55
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! coder.global(session).write(to: shared.url["hello world"]!)
        shared.load = {
            XCTAssertEqual("hello world", $0.first)
            expectLoad.fulfill()
        }
        store.loadSession {
            let loaded = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(loaded.counter, $0.counter)
            XCTAssertEqual(session.counter, $0.counter)
            XCTAssertTrue(session.projects.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalAndSharedSynched() {
        let expectLoad = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        saved.rating = Date(timeIntervalSince1970: 10)
        saved.counter = 55
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! coder.global(saved).write(to: shared.url["hello world"]!)
        shared.load = {
            XCTAssertEqual("hello world", $0.first)
            expectLoad.fulfill()
        }
        store.loadSession {
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(saved.counter, $0.counter)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSharedBiggerCounter() {
        let expect = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        saved.rating = Date(timeIntervalSince1970: 10)
        saved.counter = 55
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        saved.counter = 88
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! coder.global(saved).write(to: shared.url["hello world"]!)
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(88, session.counter)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(88, $0.counter)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalBiggerCounter() {
        let expectSave = expectation(description: "")
        let expectReady = expectation(description: "")
        Store.id = "hello world"
        store.prepare()
        let saved = Session()
        saved.rating = Date(timeIntervalSince1970: 10)
        saved.counter = 33
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        saved.counter = 11
        shared.url["hello world"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! coder.global(saved).write(to: shared.url["hello world"]!)
        shared.save = {
            XCTAssertEqual("hello world", $0)
            let global = try! self.coder.global(Data(contentsOf: $1))
            XCTAssertEqual(33, global.0)
            expectSave.fulfill()
        }
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(33, session.counter)
            XCTAssertEqual(33, $0.counter)
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
