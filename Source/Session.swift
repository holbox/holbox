import Foundation

public final class Session {
    var store = Store()
    var rating = Calendar.current.date(byAdding: .day, value: 1, to: .init())!
    var projects = [Project]()
    var perks = [Perk]()
    var settings = Settings()
    var refreshed = Date().timeIntervalSince1970
    
    public var rate: Bool { Date() >= rating }
    public var available: Int { max(capacity - count, 0) }
    public var count: Int { projects.filter { $0.mode != .off }.count }
    public var spell: Bool { settings.spell }
    public var refreshable: Bool { Date().timeIntervalSince1970 > refreshed + 30 }
    
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
    
    public class func load(result: @escaping (Session) -> Void) {
        Store().load(result)
    }
    
    public func refresh(done: @escaping () -> Void) {
        if refreshable {
            refreshed = Date().timeIntervalSince1970
            store.refresh(self, done: done)
        } else {
            DispatchQueue.main.async {
                done()
            }
        }
    }
    
    public func rated() {
        rating = Calendar.current.date(byAdding: .month, value: 3, to: .init())!
        store.save(self)
    }
    
    public func projects(_ mode: Mode) -> [Int] {
        projects.enumerated().filter { $0.1.mode == mode }.sorted { $0.1.name < $1.1.name }.map { $0.0 }
    }
    
    public func lists(_ project: Int) -> Int {
        projects[project].cards.count
    }
    
    public func cards(_ project: Int, list: Int) -> Int {
        projects[project].cards[list].1.count
    }
    
    public func purchased(_ perk: Perk) -> Bool {
        perks.contains(perk)
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
        let name = name.replacingOccurrences(of: "\n", with: "")
        guard projects[project].name != name else { return }
        projects[project].name = name
        save(project)
    }
    
    public func add(_ project: Int) {
        projects[project].cards.append((.init(), .init()))
        save(project)
    }
    
    public func name(_ project: Int, list: Int, name: String) {
        let name = name.replacingOccurrences(of: "\n", with: "")
        guard projects[project].cards[list].0 != name else { return }
        projects[project].cards[list].0 = name
        save(project)
    }
    
    public func add(_ project: Int, list: Int) {
        projects[project].cards[list].1.insert(.init(), at: 0)
        save(project)
    }
    
    public func content(_ project: Int, list: Int, card: Int, content: String) {
        guard projects[project].cards[list].1[card] != content else { return }
        projects[project].cards[list].1[card] = content
        save(project)
    }
    
    public func move(_ project: Int, list: Int, card: Int, destination: Int, index: Int) {
        guard list != destination || card != index else { return }
        projects[project].cards[destination].1.insert(projects[project].cards[list].1.remove(at: card), at: index)
        save(project)
    }
    
    public func add(_ mode: Mode) {
        let id = projects.filter { $0.mode != .off }.sorted { $0.id < $1.id }.reduce(into: 0) {
            if $1.id == $0 {
                $0 = $1.id + 1
            }
        }
        projects.removeAll { $0.id == id }
        projects.insert(.make(mode, id: id), at: 0)
        save(0)
    }
    
    public func delete(_ project: Int) {
        projects[project].mode = .off
        save(project)
    }
    
    public func delete(_ project: Int, list: Int, card: Int) {
        projects[project].cards[list].1.remove(at: card)
        save(project)
    }
    
    public func purchase(_ perk: Perk) {
        guard !perks.contains(perk) else { return }
        perks.append(perk)
        store.save(self)
    }
    
    public func spell(_ spell: Bool) {
        settings.spell = spell
        store.save(self)
    }
    
    private func save(_ project: Int) {
        projects[project].time = .init()
        store.save(self, project: projects[project])
    }
}
