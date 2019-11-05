@testable import holbox
import XCTest

final class TestSave: XCTestCase {
    private var store: Store!
    private var shared: StubShared!
    
    override func setUp() {
        shared = .init()
        store = .init()
        store.shared = shared
    }
    
    func testLoadBalancing() {
        let expect = expectation(description: "")
        let a = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("a")
        let b = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("b")
        let c = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("c")
        shared.saved = {
            XCTAssertEqual(a, $0["a"])
            XCTAssertEqual(b, $0["b"])
            XCTAssertEqual(c, $0["c"])
            XCTAssertNotEqual(a, $0["b"])
            expect.fulfill()
        }
        store.time = 0.1
        store.save(["b": b])
        store.save(["a": a])
        store.save(["c": c])
        waitForExpectations(timeout: 1)
    }
    
    func testNoDuplicates() {
        let expectA = expectation(description: "")
        let expectB = expectation(description: "")
        let a = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("a")
        let b = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("b")
        shared.saved = {
            if $0["a"] != nil {
                XCTAssertNil($0["b"])
                self.store.save(["b": b])
                expectA.fulfill()
            } else {
                XCTAssertNotNil($0["b"])
                XCTAssertNil($0["a"])
                expectB.fulfill()
            }
        }
        store.time = 0
        store.save(["a": a])
        waitForExpectations(timeout: 1)
    }
}
