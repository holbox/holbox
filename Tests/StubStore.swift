@testable import holbox
import Foundation

final class StubStore: Store {
    var session: (Session, Bool) -> Void = { _, _ in }
    var project: (Project) -> Void = { _ in }
    
    override func save(_ session: Session, share: Bool, done: (() -> Void)? = nil) {
        self.session(session, share)
        done?()
    }
    
    override func save(_ project: Project, done: (() -> Void)? = nil) {
        self.project(project)
        done?()
    }
}
