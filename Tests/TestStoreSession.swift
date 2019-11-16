@testable import holbox
import XCTest

final class TestStoreSession: XCTestCase {
    private var store: Store!
    private var shared: StubShared!
    private var coder: Coder!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp"))
        coder = .init()
        shared = .init()
        store = .init()
        store.shared = shared
        store.time = 0
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: Store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp"))
    }
    
    func testFirstTime() {
        let expectLoad = expectation(description: "")
        let expectSave = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        shared.load = {
            XCTAssertEqual("session", $0.first)
            expectLoad.fulfill()
        }
        shared.saved = {
            let global = try! self.coder.global(Data(contentsOf: $0["session"]!))
            XCTAssertTrue(global.isEmpty)
            expectSave.fulfill()
        }
        store.loadSession {
            let session = try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session")))
            XCTAssertEqual(Int(session.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertTrue(session.items.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalYesSharedNo() {
        let expectLoad = expectation(description: "")
        let expectSave = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        let saved = Session()
        saved.rating = .init(timeIntervalSince1970: 10)
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        shared.load = {
            XCTAssertEqual("session", $0.first)
            expectLoad.fulfill()
        }
        shared.saved = {
            XCTAssertNotNil(try? self.coder.global(Data(contentsOf: $0["session"]!)))
            expectSave.fulfill()
        }
        store.loadSession {
            XCTAssertEqual(Int(try! self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session"))).rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            XCTAssertEqual(Int(saved.rating.timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalNoSharedYes() {
        let expectLoad = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        let session = Session()
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! coder.global(session).write(to: shared.url["session"]!)
        shared.load = {
            XCTAssertEqual("session", $0.first)
            expectLoad.fulfill()
        }
        store.loadSession {
            XCTAssertNotNil(try? self.coder.session(Data(contentsOf: Store.url.appendingPathComponent("session"))))
            XCTAssertTrue($0.items.isEmpty)
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testLocalAndSharedSynched() {
        let expectLoad = expectation(description: "")
        let expectReady = expectation(description: "")
        store.prepare()
        let saved = Session()
        saved.rating = .init(timeIntervalSince1970: 10)
        try! coder.session(saved).write(to: Store.url.appendingPathComponent("session"))
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! coder.global(saved).write(to: shared.url["session"]!)
        shared.load = {
            XCTAssertEqual("session", $0.first)
            expectLoad.fulfill()
        }
        store.loadSession {
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int($0.rating.timeIntervalSince1970))
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
