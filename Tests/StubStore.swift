@testable import holbox
import Foundation

final class StubStore: Store {
    var save: (Session) -> Void = { _ in }
    var share: (Session) -> Void = { _ in }
    var project: (Project) -> Void = { _ in }
    
    override func save(_ session: Session, done: @escaping () -> Void) {
        save(session)
        done()
    }
    
    override func share(_ session: Session, done: @escaping () -> Void) {
        share(session)
        done()
    }
    
    override func save(_ project: Project, done: @escaping () -> Void) {
        self.project(project)
        done()
    }
}
