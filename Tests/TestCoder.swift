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
        let project1 = Project()
        let project2 = Project()
        project1.mode = .kanban
        project1.id = 88
        project1.time = time1
        project2.mode = .calendar
        project2.id = 32
        project2.time = time2
        let session = Session()
        session.rating = date
        session.counter = 9
        session.projects = [project1, project2]
        let decoded = coder.session(coder.session(session))
        XCTAssertEqual(date, decoded.rating)
        XCTAssertEqual(9, decoded.counter)
        XCTAssertEqual(2, decoded.projects.count)
        XCTAssertEqual(.off, decoded.projects.first?.mode)
        XCTAssertEqual(88, decoded.projects.first?.id)
        XCTAssertEqual(time1, decoded.projects.first?.time)
        XCTAssertEqual(.off, decoded.projects.last?.mode)
        XCTAssertEqual(32, decoded.projects.last?.id)
        XCTAssertEqual(time2, decoded.projects.last?.time)
    }
    
    func testProject() {
//        let list
//        let project = Project()
//        let session = Session()
//        session
//        project.edit(0, name: "first")
//        project.add()
//        project.edit(0, name: "second")
//        project.add()
//        project.edit(0, name: "third")
//        project.add()
//        project.edit(0, name: "fourth")
//        project.add(0)
//        project.edit(0, 0, content: "card first")
//        project.add(2)
//        project.edit(2, 0, content: "card second")
//        project.add(2)
//        project.edit(2, 1, content: "card third")
//        project.add(2)
//        
//        project.edit(2, 2, content:
//"""
//Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Facilisis magna etiam tempor orci eu lobortis elementum nibh tellus. Vel fringilla est ullamcorper eget nulla facilisi. In massa tempor nec feugiat nisl pretium fusce id. Lacinia at quis risus sed. Purus semper eget duis at tellus at urna condimentum mattis. Lacus vel facilisis volutpat est velit egestas. Turpis egestas maecenas pharetra convallis posuere. Pharetra et ultrices neque ornare aenean euismod. In arcu cursus euismod quis viverra nibh cras. Sit amet mauris commodo quis. Aenean pharetra magna ac placerat vestibulum.
//
//Ipsum a arcu cursus vitae congue mauris rhoncus. Amet cursus sit amet dictum sit amet. Adipiscing bibendum est ultricies integer quis auctor elit sed vulputate. Purus semper eget duis at. Ut eu sem integer vitae justo eget magna fermentum. Leo vel fringilla est ullamcorper eget nulla. Morbi leo urna molestie at elementum. Consectetur adipiscing elit duis tristique. Eu consequat ac felis donec et odio pellentesque diam. Facilisi morbi tempus iaculis urna id volutpat lacus. Quis blandit turpis cursus in hac habitasse platea dictumst. Pellentesque dignissim enim sit amet venenatis urna. Tellus integer feugiat scelerisque varius morbi. Id porta nibh venenatis cras.
//
//
//""")
//        project.add(2)
//        project.add(3)
//        project.add(3)
    }
}
