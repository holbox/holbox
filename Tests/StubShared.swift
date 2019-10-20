@testable import holbox
import Foundation

final class StubShared: Shared {
    var url = [String: URL]()
    var load: ([String]) -> Void = { _ in }
    var saved: ([String: URL]) -> Void = { _ in }
    
    override func load(_ ids: [String], error: @escaping () -> Void, result: @escaping ([URL]) -> Void) {
        let results = ids.compactMap { url[$0] }
        if results.count == ids.count {
            result(results)
        } else {
            error()
        }
        load(ids)
    }
    
    override func save(_ ids: [String : URL]) {
        saved(ids)
    }
}
