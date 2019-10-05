@testable import holbox
import XCTest

final class TestSession: XCTestCase {
    private var session: Session!
    
    override func setUp() {
        session = .init()
    }
    
    func testRating() {
        XCTAssertGreaterThanOrEqual(Calendar.current.date(byAdding: .day, value: 2, to: .init())!, session.rating)
        XCTAssertFalse(session.rate)
        session.rating = Calendar.current.date(byAdding: .second, value: -1, to: .init())!
        XCTAssertTrue(session.rate)
        session.rated()
        XCTAssertFalse(session.rate)
        XCTAssertGreaterThanOrEqual(Calendar.current.date(byAdding: .month, value: 3, to: .init())!, session.rating)
    }
}
