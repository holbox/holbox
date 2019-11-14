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
        XCTAssertEqual(3, mark.count)
        XCTAssertEqual(.emoji, mark[0].0)
        XCTAssertEqual(string.range(of: "🐱🦊"), mark[0].1)
        XCTAssertEqual(.plain, mark[1].0)
        XCTAssertEqual(string.range(of: "\n"), mark[1].1)
        XCTAssertEqual(.emoji, mark[2].0)
        XCTAssertEqual(string.range(of: "🐷"), mark[2].1)
    }
    
    func testSpace() {
        let string = "🐱🦊 🐷"
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(3, mark.count)
        XCTAssertEqual(.emoji, mark[0].0)
        XCTAssertEqual(string.range(of: "🐱🦊"), mark[0].1)
        XCTAssertEqual(.plain, mark[1].0)
        XCTAssertEqual(string.range(of: " "), mark[1].1)
        XCTAssertEqual(.emoji, mark[2].0)
        XCTAssertEqual(string.range(of: "🐷"), mark[2].1)
    }
    
    func testTab() {
        let string = "🐱🦊  🐷"
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(3, mark.count)
        XCTAssertEqual(.emoji, mark[0].0)
        XCTAssertEqual(string.range(of: "🐱🦊"), mark[0].1)
        XCTAssertEqual(.plain, mark[1].0)
        XCTAssertEqual(string.range(of: "  "), mark[1].1)
        XCTAssertEqual(.emoji, mark[2].0)
        XCTAssertEqual(string.range(of: "🐷"), mark[2].1)
    }
    
    func testBold() {
        let string = "#"
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(1, mark.count)
        XCTAssertEqual(.bold, mark.first?.0)
        XCTAssertEqual(string.startIndex ..< string.endIndex, mark.first?.1)
    }
    
    func testBoldLine() {
        let string = "# hello world"
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(1, mark.count)
        XCTAssertEqual(.bold, mark.first?.0)
        XCTAssertEqual(string.startIndex ..< string.endIndex, mark.first?.1)
    }
    
    func testBoldAndPlain() {
        let string = """
# hello world
lorem ipsum
"""
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(2, mark.count)
        XCTAssertEqual(.bold, mark.first?.0)
        XCTAssertEqual(string.range(of: "# hello world"), mark.first?.1)
        XCTAssertEqual(.plain, mark.last?.0)
        XCTAssertEqual(string.range(of: "\nlorem ipsum"), mark.last?.1)
    }
    
    func testBoldAndEmoji() {
            let string = """
# hello world
    🐷
"""
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(3, mark.count)
        XCTAssertEqual(.bold, mark[0].0)
        XCTAssertEqual(string.range(of: "# hello world"), mark[0].1)
        XCTAssertEqual(.plain, mark[1].0)
        XCTAssertEqual(string.range(of: "\n    "), mark[1].1)
        XCTAssertEqual(.emoji, mark[2].0)
        XCTAssertEqual(string.range(of: "🐷"), mark[2].1)
    }
    
    func testBoldAndEmojiComplex() {
                let string = """
# hello 🦊 world
    lorem ipsum
"""
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(4, mark.count)
        XCTAssertEqual(.bold, mark[0].0)
        XCTAssertEqual(string.range(of: "# hello "), mark[0].1)
        XCTAssertEqual(.emoji, mark[1].0)
        XCTAssertEqual(string.range(of: "🦊"), mark[1].1)
        XCTAssertEqual(.bold, mark[2].0)
        XCTAssertEqual(string.range(of: " world"), mark[2].1)
        XCTAssertEqual(.plain, mark[3].0)
        XCTAssertEqual(string.range(of: "\n    lorem ipsum"), mark[3].1)
    }
    
    func testBoldAndEmojiComplexNewLine() {
                    let string = """
# hello 🦊
    lorem ipsum
"""
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(3, mark.count)
        XCTAssertEqual(.bold, mark[0].0)
        XCTAssertEqual(string.range(of: "# hello "), mark[0].1)
        XCTAssertEqual(.emoji, mark[1].0)
        XCTAssertEqual(string.range(of: "🦊"), mark[1].1)
        XCTAssertEqual(.plain, mark[2].0)
        XCTAssertEqual(string.range(of: "\n    lorem ipsum"), mark[2].1)
    }
    
    func testBoldAndEmojiComplexNewLineBetween() {
                        let string = """
# hello 🦊
    🐷lorem ipsum
"""
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(5, mark.count)
        XCTAssertEqual(.bold, mark[0].0)
        XCTAssertEqual(string.range(of: "# hello "), mark[0].1)
        XCTAssertEqual(.emoji, mark[1].0)
        XCTAssertEqual(string.range(of: "🦊"), mark[1].1)
        XCTAssertEqual(.plain, mark[2].0)
        XCTAssertEqual(string.range(of: "\n    "), mark[2].1)
        XCTAssertEqual(.emoji, mark[3].0)
        XCTAssertEqual(string.range(of: "🐷"), mark[3].1)
        XCTAssertEqual(.plain, mark[4].0)
        XCTAssertEqual(string.range(of: "lorem ipsum"), mark[4].1)
    }
    
    func testEmojisGalore() {
        ["🌶", "🍏"].forEach {
            _ = $0.mark { mode, range in XCTAssertEqual(.emoji, mode) }
        }
    }
    
    func testHash() {
        let string = "#hello"
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(1, mark.count)
        XCTAssertEqual(.hash, mark.first?.0)
        XCTAssertEqual(string.startIndex ..< string.endIndex, mark.first?.1)
    }
    
    func testHashAndText() {
        let string = "#hello cat"
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(2, mark.count)
        XCTAssertEqual(.hash, mark.first?.0)
        XCTAssertEqual(.plain, mark.last?.0)
        XCTAssertEqual(string.range(of: "#hello"), mark.first?.1)
        XCTAssertEqual(string.range(of: " cat"), mark.last?.1)
    }
    
    func testHashAndBold() {
        let string = "#hello # world"
        let mark = string.mark { ($0, $1) }
        XCTAssertEqual(3, mark.count)
        XCTAssertEqual(.hash, mark[0].0)
        XCTAssertEqual(.plain, mark[1].0)
        XCTAssertEqual(.bold, mark[2].0)
        XCTAssertEqual(string.range(of: "#hello"), mark.first?.1)
        XCTAssertEqual(string.range(of: "# world"), mark.last?.1)
    }
}
