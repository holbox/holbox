@testable import holbox
import XCTest

final class TestMark: XCTestCase {
    func testEmpty() {
        _ = "".mark { _, _ in
            XCTFail()
        }
    }
    
    func testPlain() {
        let string = "hello world"
        XCTAssertEqual(1, string.mark {
            XCTAssertEqual(.plain, $0)
            XCTAssertEqual(string.startIndex ..< string.endIndex, $1)
        }.count)
    }
    
    func testEmoji() {
        let string = "🐱"
        XCTAssertEqual(1, string.mark {
            XCTAssertEqual(.emoji, $0)
            XCTAssertEqual(string.startIndex ..< string.endIndex, $1)
        }.count)
    }
    
    func testTextAndEmoji() {
        let string = "a🐱"
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(2, mark.count)
        XCTAssertEqual(.plain, mark.first?.0)
        XCTAssertEqual(.emoji, mark.last?.0)
        XCTAssertEqual(string.range(of: "a"), mark.first?.1)
        XCTAssertEqual(string.range(of: "🐱"), mark.last?.1)
    }
    
    func testLineBreak() {
        let string = """
🐱🦊
🐷
"""
        let mark = string.mark { ($0, $1) }
        print(mark)
        XCTAssertEqual(1, mark.count)
        XCTAssertEqual(.emoji, mark.first?.0)
        XCTAssertEqual(string.range(of: "🐱🦊\n🐷"), mark.first?.1)
    }
    
    func testSpace() {
        let string = "🐱🦊 🐷"
        let mark = string.mark { ($0, $1) }
        print(mark)
        XCTAssertEqual(1, mark.count)
        XCTAssertEqual(.emoji, mark.first?.0)
        XCTAssertEqual(string.range(of: "🐱🦊 🐷"), mark.first?.1)
    }
    
    func testTab() {
        let string = "🐱🦊  🐷"
        let mark = string.mark { ($0, $1) }
        print(mark)
        XCTAssertEqual(1, mark.count)
        XCTAssertEqual(.emoji, mark.first?.0)
        XCTAssertEqual(string.range(of: "🐱🦊  🐷"), mark.first?.1)
    }
}
