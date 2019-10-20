@testable import holbox
import Foundation

final class StubStore: Store {
    var session: (Session) -> Void = { _ in }
    var project: (Session, Project) -> Void = { _, _ in }
    
    override func save(_ session: Session) {
        self.session(session)
    }
    
    override func save(_ session: Session, project: Project) {
        self.project(session, project)
    }
}
