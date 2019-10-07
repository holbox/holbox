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
    
    public func projects(_ mode: Mode) -> [Int] {
        projects.filter { $0.mode == mode }.map { $0.id }
    }
    
    public func name(_ id: Int) -> String {
        projects.first { $0.id == id }!.name
    }
    
    public func lists(_ id: Int) -> Int {
        projects.first { $0.id == id }!.lists.count
    }
    
    public func add(_ project: Int) {
        projects.first { $0.id == project }!.lists.append(.init())
        save(project)
    }
    
    public func name(_ project: Int, list: Int, name: String) {
        projects.first { $0.id == project }!.lists[list].name = name
        save(project)
    }
    
    public func add(_ project: Int, list: Int) {
        projects.first { $0.id == project }!.lists[list].cards.append("")
        save(project)
    }
    
    public func content(_ project: Int, list: Int, card: Int, content: String) {
        projects.first { $0.id == project }!.lists[list].cards[card] = content
        save(project)
    }
    
    public func add(_ mode: Mode) {
        let project = Project()
        project.id = counter
        project.mode = mode
        projects.append(project)
        counter += 1
        save(project.id)
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
    
    private func save(_ project: Int) {
        projects.first { $0.id == project }!.time = .init()
        store.save(projects.first { $0.id == project }!)
        store.save(self)
    }
}
