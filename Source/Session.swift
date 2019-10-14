import Foundation

public final class Session {
    var store = Store()
    var rating = Calendar.current.date(byAdding: .day, value: 2, to: .init())!
    var counter = 0
    var projects = [Project]()
    var perks = [Perk]()
    
    public var rate: Bool { Date() >= rating }
    
    public var available: Int { max(capacity - projects.filter { $0.mode != .off }.count, 0) }
    
    public var capacity: Int {
        var result = 1
        perks.forEach {
            switch $0 {
            case .two: result += 2
            case .ten: result += 10
            case .hundred: result += 100
            default: break
            }
        }
        return result
    }
    
    public class func load(result: @escaping(Session) -> Void) {
        Store().load(result)
    }
    
    public func rated() {
        rating = Calendar.current.date(byAdding: .month, value: 3, to: .init())!
        store.save(self)
    }
    
    public func projects(_ mode: Mode) -> [Int] {
        projects.enumerated().filter { $0.1.mode == mode }.map { $0.0 }
    }
    
    public func lists(_ project: Int) -> Int {
        projects[project].cards.count
    }
    
    public func cards(_ project: Int, list: Int) -> Int {
        projects[project].cards[list].1.count
    }
    
    public func name(_ project: Int) -> String {
        projects[project].name
    }
    
    public func name(_ project: Int, list: Int) -> String {
        projects[project].cards[list].0
    }
    
    public func content(_ project: Int, list: Int, card: Int) -> String {
        projects[project].cards[list].1[card]
    }
    
    public func name(_ project: Int, name: String) {
        projects[project].name = name
        save(project)
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
        projects.append(Project.make(mode, counter: counter))
        counter += 1
        save(projects.count - 1)
    }
    
    public func delete(_ project: Int) {
        projects[project].mode = .off
        save(project)
    }
    
    private func save(_ project: Int) {
        projects[project].time = .init()
        store.save(projects[project]) { [weak self] in
            guard let self = self else { return }
            self.store.save(self)
        }
    }
}
