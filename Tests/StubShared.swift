@testable import holbox
import Foundation

final class StubShared: Shared {
    var global: Session.Global?
    
    override func load(_ error: @escaping () -> Void, success: @escaping (Session.Global) -> Void) {
        if let global = self.global {
            success(global)
        } else {
            error()
        }
    }
}
