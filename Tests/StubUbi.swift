import Foundation

final class StubUbi: NSUbiquitousKeyValueStore {
    var string: String?
    
    override func synchronize() -> Bool { true }
    override func string(forKey aKey: String) -> String? { string }
    override func set(_ aString: String?, forKey aKey: String) { string = aString }
}
