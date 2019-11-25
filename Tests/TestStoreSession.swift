@testable import holbox
import XCTest

final class TestStoreSession: XCTestCase {
    private var store: Store!
    private var shared: StubShared!
    private var coder: Coder!
    private var session: Session!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp"))
        coder = .init()
        shared = .init()
        store = .init()
        session = .init()
        try? FileManager.default.removeItem(at: store.url)
        store.shared = shared
        store.time = 0
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: store.url)
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
            let global = try! self.coder.global(.init(contentsOf: $0["session"]!))
            XCTAssertTrue(global.isEmpty)
            expectSave.fulfill()
        }
        store.load(session: session) {
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session")))
            XCTAssertEqual(Int(session.rating.timeIntervalSince1970), Int(self.session.rating.timeIntervalSince1970))
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
        try! coder.session(saved).write(to: store.url.appendingPathComponent("session"))
        shared.load = {
            XCTAssertEqual("session", $0.first)
            expectLoad.fulfill()
        }
        shared.saved = {
            XCTAssertNotNil(try? self.coder.global(.init(contentsOf: $0["session"]!)))
            expectSave.fulfill()
        }
        store.load(session: session) {
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session")))
            XCTAssertEqual(Int(session.rating.timeIntervalSince1970), Int(self.session.rating.timeIntervalSince1970))
            XCTAssertEqual(Int(saved.rating.timeIntervalSince1970), Int(self.session.rating.timeIntervalSince1970))
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
        store.load(session: session) {
            try! XCTAssertNoThrow(self.coder.session(.init(), data: .init(contentsOf: self.store.url.appendingPathComponent("session"))))
            XCTAssertTrue(self.session.items.isEmpty)
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
        try! coder.session(saved).write(to: store.url.appendingPathComponent("session"))
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp")
        try! coder.global(saved).write(to: shared.url["session"]!)
        shared.load = {
            XCTAssertEqual("session", $0.first)
            expectLoad.fulfill()
        }
        store.load(session: session) {
            XCTAssertEqual(.init(Date(timeIntervalSince1970: 10).timeIntervalSince1970), Int(self.session.rating.timeIntervalSince1970))
            expectReady.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
