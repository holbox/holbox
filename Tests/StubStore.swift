@testable import holbox
import Foundation

final class StubStore: Store {
    var session: (Session) -> Void = { _ in }
    var project: (Project) -> Void = { _ in }
    
    override func save(_ session: Session) { self.session(session) }
    override func save(_ project: Project) { self.project(project) }
}
