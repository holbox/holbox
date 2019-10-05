@testable import holbox
import XCTest

final class TestStore: XCTestCase {
    private var store: Store!
    private var ubi: StubUbi!
    
    override func setUp() {
        ubi = .init()
        store = .init()
        store.ubi = ubi
        try? FileManager.default.removeItem(at: store.url)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: store.url)
    }
    
    func testLoadIdFirstTime() {
        store.loadId()
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.url.path))
        XCTAssertFalse(Store.id.isEmpty)
        XCTAssertEqual(ubi.string, Store.id)
        XCTAssertEqual(Store.id, try! String(decoding: Data(contentsOf: store.url.appendingPathComponent("id")), as: UTF8.self))
    }
    
    func testLoadIdSecondTime() {
        store.prepare()
        try! Data("hello world".utf8).write(to: store.url.appendingPathComponent("id"))
        store.loadId()
        XCTAssertEqual("hello world", Store.id)
    }
    
    func testLoadIdWithUbi() {
        ubi.string = "hello world"
        store.loadId()
        XCTAssertEqual("hello world", Store.id)
        XCTAssertEqual(Store.id, try! String(decoding: Data(contentsOf: store.url.appendingPathComponent("id")), as: UTF8.self))
    }
}
