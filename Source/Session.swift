import Foundation

public final class Session: Codable {
    struct Project: Codable {
        var id = 0
        var time = Int(Date().timeIntervalSince1970)
        var active = true
    }
    
    struct Global: Codable {
        var time = Int(Date().timeIntervalSince1970)
        var counter = 0
        var projects = [Project]()
    }
    
    public var rate: Bool { Date() >= rating }
    var store = Store()
    var global = Global()
    var rating = Calendar.current.date(byAdding: .day, value: 2, to: .init())!
    
    public func rated() {
        rating = Calendar.current.date(byAdding: .month, value: 3, to: .init())!
        store.save(self)
    }
    
    private enum CodingKeys: CodingKey {
        case rating, global
    }
}
