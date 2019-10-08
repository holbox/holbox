@testable import holbox
import Foundation

final class StubShared: Shared {
    var url = [String: URL]()
    var load: (String) -> Void = { _ in }
    var save: (String, URL) -> Void = { _, _ in }
    
    override func load(_ id: String, error: @escaping () -> Void, success: @escaping (URL) -> Void) {
        if let url = self.url[id] {
            success(url)
        } else {
            error()
        }
        load(id)
    }
    
    override func save(_ id: String, url: URL) {
        save(id, url)
    }
}
