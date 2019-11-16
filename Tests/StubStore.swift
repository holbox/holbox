@testable import holbox
import Foundation

final class StubStore: Store {
    var session: (Session) -> Void = { _ in }
    var project: (Session, Int, Project) -> Void = { _, _, _ in }
    var refresh: (Session) -> Void = { _ in }
    
    override func save(_ session: Session) {
        self.session(session)
    }
    
    override func save(_ session: Session, id: Int, project: Project) {
        self.project(session, id, project)
    }
    
    override func refresh(_ session: Session, done: @escaping () -> Void) {
        self.refresh(session)
        done()
    }
}
