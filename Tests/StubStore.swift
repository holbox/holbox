@testable import holbox
import Foundation

final class StubStore: Store {
    var session: (Session) -> Void = { _ in }
    var project: (Project) -> Void = { _ in }
    
    override func save(_ session: Session, done: (() -> Void)? = nil) {
        self.session(session)
        done?()
    }
    
    override func save(_ project: Project, done: (() -> Void)? = nil) {
        self.project(project)
        done?()
    }
}
