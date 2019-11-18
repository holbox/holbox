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
            self.session.tags(0, compare: [], same: {
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }) { _ in
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneTag() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual("hello", $0[0].0)
            XCTAssertEqual(1, $0[0].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneTagAndText() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["hello #world"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual("world", $0[0].0)
            XCTAssertEqual(1, $0[0].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneTagAndMoreText() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["hello #world lorem"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual("world", $0[0].0)
            XCTAssertEqual(1, $0[0].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTwoTags() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello #world"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(2, $0.count)
            XCTAssertEqual("hello", $0[0].0)
            XCTAssertEqual(1, $0[0].1)
            XCTAssertEqual("world", $0[1].0)
            XCTAssertEqual(1, $0[1].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRepeat() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello #hello"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual("hello", $0[0].0)
            XCTAssertEqual(2, $0[0].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRepeatDifferentColumns() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello", "#hello"]), ("", ["#hello #hello"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual("hello", $0[0].0)
            XCTAssertEqual(4, $0[0].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testJoined() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello#world"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(2, $0.count)
            XCTAssertEqual("hello", $0[0].0)
            XCTAssertEqual(1, $0[0].1)
            XCTAssertEqual("world", $0[1].0)
            XCTAssertEqual(1, $0[1].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSortedByCount() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello#world#world"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(2, $0.count)
            XCTAssertEqual("world", $0[0].0)
            XCTAssertEqual(2, $0[0].1)
            XCTAssertEqual("hello", $0[1].0)
            XCTAssertEqual(1, $0[1].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testSortedByNameIfCoundSame() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#world#world#Hello#Hello"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(2, $0.count)
            XCTAssertEqual("hello", $0[0].0)
            XCTAssertEqual(2, $0[0].1)
            XCTAssertEqual("world", $0[1].0)
            XCTAssertEqual(2, $0[1].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testMakeLowerCased() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello", "#Hello"]), ("", ["#Hello #hello"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual("hello", $0[0].0)
            XCTAssertEqual(4, $0[0].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneTagAndBold() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["# hello #world"])]
        session.tags(0, compare: [], same: {
            XCTFail()
        }) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual("world", $0[0].0)
            XCTAssertEqual(1, $0[0].1)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOnlyIfNew() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello"])]
        session.tags(0, compare: [("hello", 1)], same: {
            expect.fulfill()
        }) { _ in
            XCTFail()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testIfCountChanged() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello #hello"])]
        session.tags(0, compare: [("hello", 1)], same: {
            XCTFail()
        }) { _ in
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testAdded() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["#hello #world"])]
        session.tags(0, compare: [("hello", 1)], same: {
            XCTFail()
        }) { _ in
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
