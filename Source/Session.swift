import Foundation

public final class Session {
    public enum Mode: UInt8 {
        case off, kanban, check, shopping, calendar
    }
    
    struct Item {
        var id = 0
        var time = Date()
        var mode = Mode.off
    }
    
    struct Global {
        var counter = 0
        var items = [Item]()
    }
    
    public var rate: Bool { Date() >= rating }
    public var kanban: [Project] { projects.filter { project in global.items.first { project.id == $0.id }!.mode == .kanban } }
    var store = Store()
    var global = Global()
    var rating = Calendar.current.date(byAdding: .day, value: 2, to: .init())!
    private(set) var projects = [Project]()
    
    public func rated() {
        rating = Calendar.current.date(byAdding: .month, value: 3, to: .init())!
        store.save(self)
    }
    
    public func add(_ mode: Mode) {
        var item = Item()
        let project = Project()
        item.id = global.counter
        item.mode = mode
        project.id = global.counter
        global.items.append(item)
        global.counter += 1
        projects.append(project)
        store.save(self)
        store.save(project)
    }
}
