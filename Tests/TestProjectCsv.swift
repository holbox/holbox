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
                let data = try? Data(contentsOf: $0)
                XCTAssertEqual(.main, Thread.current)
                XCTAssertNotNil(data)
                XCTAssertEqual("", String(decoding: data!, as: UTF8.self))
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneCell() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("Waiting", ["hello"])]
        session.csv(0) {
            try! XCTAssertEqual("Waiting\nhello", String(decoding: Data(contentsOf: $0), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTwoCells() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("Waiting", ["hello", "world"])]
        session.csv(0) {
            try! XCTAssertEqual("Waiting\nhello\nworld", String(decoding: Data(contentsOf: $0), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testTwoCols() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("Waiting", ["hello"]), ("Doing", ["world"])]
        session.csv(0) {
            try! XCTAssertEqual("Waiting,Doing\nhello,world", String(decoding: Data(contentsOf: $0), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testOneColBigger() {
        let expect = expectation(description: "")
        session.items[0]!.cards = [("Waiting", ["hello"]), ("Doing", ["world", "lorem", "ipsum"])]
        session.csv(0) {
            try! XCTAssertEqual("Waiting,Doing\nhello,world\n,lorem\n,ipsum", String(decoding: Data(contentsOf: $0), as: UTF8.self))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
