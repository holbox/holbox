@testable import holbox
import XCTest

final class TestProjectTags: XCTestCase {
    private var session: Session!
    
    override func setUp() {
        session = .init()
        session.store = StubStore()
        var project = Project()
        project.mode = .kanban
        session.items[0] = project
    }
    
    func testEmpty() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.session.tags(0) {
                XCTAssertTrue($0.isEmpty)
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneTag() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello"])]
        session.tags(0) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(1, $0["hello"])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneTagAndText() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["hello #world"])]
        session.tags(0) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(1, $0["world"])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneTagAndMoreText() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["hello #world lorem"])]
        session.tags(0) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(1, $0["world"])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTwoTags() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello #world"])]
        session.tags(0) {
            XCTAssertEqual(2, $0.count)
            XCTAssertEqual(1, $0["hello"])
            XCTAssertEqual(1, $0["world"])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRepeat() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello #hello"])]
        session.tags(0) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(2, $0["hello"])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRepeatDifferentColumns() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello", "#hello"]), ("", ["#hello #hello"])]
        session.tags(0) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(4, $0["hello"])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testJoined() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello#world"])]
        session.tags(0) {
            XCTAssertEqual(2, $0.count)
            XCTAssertEqual(1, $0["hello"])
            XCTAssertEqual(1, $0["world"])
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
