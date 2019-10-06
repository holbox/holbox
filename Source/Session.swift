import Foundation

public final class Session {
    enum Mode: UInt8 {
        case off, kanban, check, shopping, calendar
    }
    
    struct Project {
        var id = 0
        var time = Date()
        var mode = Mode.off
    }
    
    struct Global {
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
}
