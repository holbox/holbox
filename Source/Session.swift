import Foundation

public final class Session {
    public var rate: Bool { Date() >= rating }
    var store = Store()
    var rating = Calendar.current.date(byAdding: .day, value: 2, to: .init())!
    var counter = 0
    var projects = [Project]()
    
    public func rated() {
        rating = Calendar.current.date(byAdding: .month, value: 3, to: .init())!
        store.save(self)
    }
    
    public func count(_ mode: Mode) -> Int {
        projects.filter { $0.mode == mode }.count
    }
    
    public func name(_ id: Int) -> String {
        projects.first { $0.id == id }!.name
    }
    
    public func lists(_ id: Int) -> Int {
        projects.first { $0.id == id }!.lists.count
    }
    
    public func add(_ mode: Mode) {
        let project = Project()
        project.id = counter
        project.mode = mode
        counter += 1
        projects.append(project)
        store.save(self)
        store.save(project)
    }
    
    public func overwrite(_ shared: (Int, [(Int, Date)])) {
        counter = shared.0
        projects = shared.1.map {
            let project = Project()
            project.id = $0.0
            project.time = $0.1
            return project
        }
    }
}
