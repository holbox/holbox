@testable import holbox
import XCTest

final class TestCoder: XCTestCase {
    private var coder: Coder!
    
    override func setUp() {
        coder = .init()
    }
    
    func testSession() {
        let date = Date(timeIntervalSince1970: 150)
        let time1 = Date(timeIntervalSince1970: 250)
        let time2 = Date(timeIntervalSince1970: 350)
        var item1 = Session.Item()
        var item2 = Session.Item()
        item1.mode = .kanban
        item1.id = 88
        item1.time = time1
        item2.mode = .calendar
        item2.id = 32
        item2.time = time2
        let session = Session()
        session.rating = date
        session.global.counter = 9
        session.global.items = [item1, item2]
        let decoded = coder.session(coder.code(session))
        XCTAssertEqual(date, decoded.rating)
        XCTAssertEqual(9, decoded.global.counter)
        XCTAssertEqual(2, decoded.global.items.count)
        XCTAssertEqual(.kanban, decoded.global.items.first?.mode)
        XCTAssertEqual(88, decoded.global.items.first?.id)
        XCTAssertEqual(time1, decoded.global.items.first?.time)
        XCTAssertEqual(.calendar, decoded.global.items.last?.mode)
        XCTAssertEqual(32, decoded.global.items.last?.id)
        XCTAssertEqual(time2, decoded.global.items.last?.time)
    }
    
    func testProject() {
        let project = Project()
    }
}
