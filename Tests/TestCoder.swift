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
        var project1 = Session.Project()
        var project2 = Session.Project()
        project1.mode = .kanban
        project1.id = 88
        project1.time = time1
        project2.mode = .calendar
        project2.id = 32
        project2.time = time2
        let session = Session()
        session.rating = date
        session.global.counter = 9
        session.global.projects = [project1, project2]
        let decoded = coder.session(coder.code(session))
        XCTAssertEqual(date, decoded.rating)
        XCTAssertEqual(9, decoded.global.counter)
        XCTAssertEqual(2, decoded.global.projects.count)
        XCTAssertEqual(.kanban, decoded.global.projects.first?.mode)
        XCTAssertEqual(88, decoded.global.projects.first?.id)
        XCTAssertEqual(time1, decoded.global.projects.first?.time)
        XCTAssertEqual(.calendar, decoded.global.projects.last?.mode)
        XCTAssertEqual(32, decoded.global.projects.last?.id)
        XCTAssertEqual(time2, decoded.global.projects.last?.time)
        
    }
}
