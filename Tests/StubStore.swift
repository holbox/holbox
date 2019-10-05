@testable import holbox
import Foundation

final class StubStore: Store {
    var save = {  }
    
    override func save(_ session: Session) { save() }
    override func save(_ project: Project) { save() }
}
