@testable import holbox
import Foundation

final class StubShared: Shared {
    var id = ""
    var url = [String: URL]()
    var load: ([String]) -> Void = { _ in }
    var save: ([String: URL]) -> Void = { _ in }
    var refreshed: (String) -> Void = { _ in }
    
    override func load(_ result: @escaping (String) -> Void) {
        result(id)
    }
    
    override func load(_ ids: [String], result: @escaping ([String : URL]) -> Void) {
        result(ids.reduce(into: [:]) { $0[$1] = url[$1] })
        load(ids)
    }
    
    override func save(_ ids: [String : URL], done: @escaping () -> Void) {
        save(ids)
        done()
    }
    
    override func refresh(_ id: String) {
        refreshed(id)
    }
}
