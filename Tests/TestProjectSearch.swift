@testable import holbox
import XCTest

final class TestProjectSearch: XCTestCase {
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
            self.session.search(0, string: "") {
                XCTAssertTrue($0.isEmpty)
                XCTAssertEqual(.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNoCards() {
        let expect = expectation(description: "")
        session.search(0, string: "hello") {
            XCTAssertTrue($0.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCardsNoMatch() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["world"])]
        session.search(0, string: "hello") {
            XCTAssertTrue($0.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneMatch() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["hello"])]
        session.search(0, string: "hello") {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(0, $0.first?.0)
            XCTAssertEqual(0, $0.first?.1)
            XCTAssertEqual(.init(location: 0, length: 5), $0.first?.2)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneMatchIgnoreCase() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["hello"])]
        session.search(0, string: "Hello") {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(0, $0.first?.0)
            XCTAssertEqual(0, $0.first?.1)
            XCTAssertEqual(.init(location: 0, length: 5), $0.first?.2)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneMatchEmptySpace() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["hello"])]
        session.search(0, string: "hello \n") {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(0, $0.first?.0)
            XCTAssertEqual(0, $0.first?.1)
            XCTAssertEqual(.init(location: 0, length: 5), $0.first?.2)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTwoMatches() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["", "hello world hello", ""])]
        session.search(0, string: "hello") {
            XCTAssertEqual(2, $0.count)
            XCTAssertEqual(0, $0.first?.0)
            XCTAssertEqual(1, $0.first?.1)
            XCTAssertEqual(.init(location: 0, length: 5), $0.first?.2)
            XCTAssertEqual(0, $0.last?.0)
            XCTAssertEqual(1, $0.last?.1)
            XCTAssertEqual(.init(location: 12, length: 5), $0.last?.2)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testCancelPrevious() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("", ["hello", "world"]), ("", ["hello", "world"]), ("", ["lorem ipsum", "world"])]
        session.search(0, string: "hello") { _ in
            XCTFail()
        }
        session.search(0, string: "world") { _ in
            XCTFail()
        }
        session.search(0, string: "lorem") {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(2, $0.first?.0)
            XCTAssertEqual(0, $0.first?.1)
            XCTAssertEqual(.init(location: 0, length: 5), $0.first?.2)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testWithEmoji() {
        let expect = expectation(description: "")
        let text = "🙆🏻‍♀️ hello"
        session.items[0]!.cards = [("", [text])]
        session.search(0, string: "hello") {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(0, $0.first?.0)
            XCTAssertEqual(0, $0.first?.1)
            XCTAssertEqual(.init(location: 8, length: 5), $0.first?.2)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
