@testable import holbox
import Foundation

final class StubShared: Shared {
    var url = [String: URL]()
    var load: ([String]) -> Void = { _ in }
    var save: (String, URL) -> Void = { _, _ in }
    
    override func load(_ ids: [String], result: @escaping ([String : URL]) -> Void) {
        result(ids.reduce(into: [:]) { $0[$1] = url[$1] })
        load(ids)
    }
    
    override func save(_ id: String, url: URL, done: @escaping () -> Void) {
        save(id, url)
        done()
    }
}
