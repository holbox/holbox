@testable import holbox
import Foundation

final class StubShared: Shared {
    var global: Session.Global?
    
    override func load(_ success: @escaping (Session.Global) -> Void, error: @escaping () -> Void) {
        if let global = self.global {
            success(global)
        } else {
            error()
        }
    }
}
