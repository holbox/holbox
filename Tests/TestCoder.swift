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
        project.add()
        project.edit(0, name: "first")
        project.add()
        project.edit(0, name: "second")
        project.add()
        project.edit(0, name: "third")
        project.add()
        project.edit(0, name: "fourth")
        project.add(0)
        project.edit(0, 0, content: "card first")
        project.add(2)
        project.edit(2, 0, content: "card second")
        project.add(2)
        project.edit(2, 1, content: "card third")
        project.add(2)
        
        project.edit(2, 2, content:
"""
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Facilisis magna etiam tempor orci eu lobortis elementum nibh tellus. Vel fringilla est ullamcorper eget nulla facilisi. In massa tempor nec feugiat nisl pretium fusce id. Lacinia at quis risus sed. Purus semper eget duis at tellus at urna condimentum mattis. Lacus vel facilisis volutpat est velit egestas. Turpis egestas maecenas pharetra convallis posuere. Pharetra et ultrices neque ornare aenean euismod. In arcu cursus euismod quis viverra nibh cras. Sit amet mauris commodo quis. Aenean pharetra magna ac placerat vestibulum.

Ipsum a arcu cursus vitae congue mauris rhoncus. Amet cursus sit amet dictum sit amet. Adipiscing bibendum est ultricies integer quis auctor elit sed vulputate. Purus semper eget duis at. Ut eu sem integer vitae justo eget magna fermentum. Leo vel fringilla est ullamcorper eget nulla. Morbi leo urna molestie at elementum. Consectetur adipiscing elit duis tristique. Eu consequat ac felis donec et odio pellentesque diam. Facilisi morbi tempus iaculis urna id volutpat lacus. Quis blandit turpis cursus in hac habitasse platea dictumst. Pellentesque dignissim enim sit amet venenatis urna. Tellus integer feugiat scelerisque varius morbi. Id porta nibh venenatis cras.


""")
        project.add(2)
        project.add(3)
        project.add(3)
    }
}
