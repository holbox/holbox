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
        var project1 = Project()
        var project2 = Project()
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
        var project = Project()
        project.id = 99
        project.mode = .shopping
        project.cards = [(.init(), .init()), ("first", .init()), ("second", ["card first", "card second", "card third", "card card", "third card"]), ("third", ["""
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Elementum nisi quis eleifend quam adipiscing vitae proin sagittis. Facilisis magna etiam tempor orci eu lobortis elementum nibh tellus. Vel fringilla est ullamcorper eget nulla facilisi. In massa tempor nec feugiat nisl pretium fusce id. Lacinia at quis risus sed. Purus semper eget duis at tellus at urna condimentum mattis. Lacus vel facilisis volutpat est velit egestas. Turpis egestas maecenas pharetra convallis posuere. Pharetra et ultrices neque ornare aenean euismod. In arcu cursus euismod quis viverra nibh cras. Sit amet mauris commodo quis. Aenean pharetra magna ac placerat vestibulum.

        Ipsum a arcu cursus vitae congue mauris rhoncus. Amet cursus sit amet dictum sit amet. Adipiscing bibendum est ultricies integer quis auctor elit sed vulputate. Purus semper eget duis at. Ut eu sem integer vitae justo eget magna fermentum. Leo vel fringilla est ullamcorper eget nulla. Morbi leo urna molestie at elementum. Consectetur adipiscing elit duis tristique. Eu consequat ac felis donec et odio pellentesque diam. Facilisi morbi tempus iaculis urna id volutpat lacus. Quis blandit turpis cursus in hac habitasse platea dictumst. Pellentesque dignissim enim sit amet venenatis urna. Tellus integer feugiat scelerisque varius morbi. Id porta nibh venenatis cras.


        """]), ("fourth", ["", "", ""])]
        project.time = .init(timeIntervalSince1970: 155)
        let decoded = coder.project(coder.project(project))
        XCTAssertEqual(0, decoded.id)
        XCTAssertEqual(.shopping, decoded.mode)
        XCTAssertEqual(.init(timeIntervalSince1970: 155), decoded.time)
        XCTAssertEqual(5, decoded.cards.count)
        XCTAssertEqual("first", decoded.cards[1].0)
        XCTAssertEqual("second", decoded.cards[2].0)
        XCTAssertEqual("third", decoded.cards[3].0)
        XCTAssertEqual("card first", decoded.cards[2].1[0])
        XCTAssertEqual("card second", decoded.cards[2].1[1])
        XCTAssertEqual("card third", decoded.cards[2].1[2])
        XCTAssertEqual("card card", decoded.cards[2].1[3])
        XCTAssertEqual("third card", decoded.cards[2].1[4])
        XCTAssertEqual(project.cards[3].1[0], decoded.cards[3].1[0])
        XCTAssertEqual("", decoded.cards[4].1[0])
        XCTAssertEqual("", decoded.cards[4].1[1])
        XCTAssertTrue(decoded.cards[0].1.isEmpty)
        XCTAssertTrue(decoded.cards[1].1.isEmpty)
        XCTAssertEqual(5, decoded.cards[2].1.count)
        XCTAssertEqual(1, decoded.cards[3].1.count)
        XCTAssertEqual(3, decoded.cards[4].1.count)
    }
}
