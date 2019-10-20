@testable import holbox
import Foundation

final class StubUbi: Ubi {
    var id = ""
    
    override func load(_ result: @escaping (String) -> Void) {
        result(id)
    }
}
