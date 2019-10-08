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
        projects.enumerated().filter { $0.1.mode == mode }.map { $0.0 }
    }
    
    public func name(_ project: Int) -> String {
        projects[project].name
    }
    
    public func lists(_ project: Int) -> Int {
        projects[project].cards.count
    }
    
    public func add(_ project: Int) {
        projects[project].cards.append((.init(), .init()))
        save(project)
    }
    
    public func name(_ project: Int, list: Int, name: String) {
        projects[project].cards[list].0 = name
        save(project)
    }
    
    public func add(_ project: Int, list: Int) {
        projects[project].cards[list].1.append(.init())
        save(project)
    }
    
    public func content(_ project: Int, list: Int, card: Int, content: String) {
        projects[project].cards[list].1[card] = content
        save(project)
    }
    
    public func add(_ mode: Mode) {
        var project = Project()
        project.id = counter
        project.mode = mode
        projects.append(project)
        counter += 1
        save(projects.count - 1)
    }
    
    public func overwrite(_ global: (Int, [(Int, Date)])) {
        counter = global.0
        projects = global.1.map {
            var project = Project()
            project.id = $0.0
            project.time = $0.1
            return project
        }
    }
    
    private func save(_ project: Int) {
        projects[project].time = .init()
        store.save(projects[project])
        store.save(self)
    }
}
