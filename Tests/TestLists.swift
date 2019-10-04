@testable import holbox
import XCTest

final class TestLists: XCTestCase {
    private var project: Project!
    
    override func setUp() {
        project = .init()
    }
    
    func testAddList() {
        XCTAssertEqual(0, project.count)
        project.add()
        XCTAssertEqual(1, project.count)
        project.edit(0, name: "hello world")
        XCTAssertEqual("hello world", project.name(0))
    }
}
