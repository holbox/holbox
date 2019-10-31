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
            XCTAssertEqual(.none, $0)
            XCTAssertEqual(string.startIndex ..< string.endIndex, $1)
        }.count)
    }
}
