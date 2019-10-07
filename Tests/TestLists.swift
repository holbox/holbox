@testable import holbox
import XCTest

final class TestLists: XCTestCase {
    private var project: Project!
    private var store: StubStore!
    
    override func setUp() {
        store = .init()
        project = .init()
        project.store = store
    }
    
    func testAdd() {
        XCTAssertEqual(0, project.count)
        project.add()
        XCTAssertEqual(1, project.count)
        project.edit(0, name: "hello world")
        XCTAssertEqual("hello world", project.name(0))
    }
    
    func testSaveOnAdd() {
        let expect = expectation(description: "")
        store.project = {
            XCTAssertEqual(1, $0.count)
            expect.fulfill()
        }
        project.add()
        waitForExpectations(timeout: 1)
    }
    
    func testSaveOnEdit() {
        let expect = expectation(description: "")
        project.add()
        store.project = {
            XCTAssertEqual("hello world", $0.name(0))
            expect.fulfill()
        }
        project.edit(0, name: "hello world")
        waitForExpectations(timeout: 1)
    }
}
