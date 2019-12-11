@testable import holbox
import XCTest

final class TestProjectCsv: XCTestCase {
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
            self.session.csv(0) {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertEqual("", String(decoding: $0, as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneCell() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("Waiting", ["hello"])]
        session.csv(0) {
            XCTAssertEqual("\"Waiting\"\n\"hello\"", String(decoding: $0, as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTwoCells() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("Waiting", ["hello", "world"])]
        session.csv(0) {
            XCTAssertEqual("\"Waiting\"\n\"hello\"\n\"world\"", String(decoding: $0, as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTwoCols() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("Waiting", ["hello"]), ("Doing", ["world"])]
        session.csv(0) {
            XCTAssertEqual("\"Waiting\",\"Doing\"\n\"hello\",\"world\"", String(decoding: $0, as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneColBigger() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("Waiting", ["hello"]), ("Doing", ["world", "lorem", "ipsum"])]
        session.csv(0) {
            XCTAssertEqual("\"Waiting\",\"Doing\"\n\"hello\",\"world\"\n,\"lorem\"\n,\"ipsum\"", String(decoding: $0, as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testEscape() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("Waiting \"here\" ", ["hello \"world\" "])]
        session.csv(0) {
            XCTAssertEqual("""
"Waiting ""here"" "
"hello ""world"" "
""", String(decoding: $0, as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
