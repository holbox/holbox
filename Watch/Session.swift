import holbox
import Foundation

final class Session: ObservableObject {
    @Published private(set) var loading = true
    @Published private(set) var projects = [Int]()
    var session: holbox.Session? { didSet { update() } }
    var available: Int { session?.available ?? 0 }
    let mode = Mode.kanban
    
    func load() {
        if session == nil {
            holbox.Session.load {
                self.session = $0
            }
        }
    }
    
    func refresh() {
        if let session = self.session {
            if session.refreshable {
                self.session = nil
                session.refresh {
                    self.session = session
                }
            }
        }
    }
    
    func name(_ project: Int) -> String {
        session?.name(project) ?? ""
    }
    
    func name(_ project: Int, name: String) {
        session?.name(project, name: name)
        update()
    }
    
    func lists(_ project: Int) -> Int {
        session?.lists(project) ?? 0
    }
    
    func add() {
        session?.add(mode)
        update()
    }
    
    func delete(_ project: IndexSet) {
        guard let session = self.session else { return }
        session.delete(session.projects(mode)[project.first!])
        update()
    }
    
    func name(_ project: Int, list: Int) -> String {
        session?.name(project, list: list) ?? ""
    }
    
    func cards(_ project: Int, list: Int) -> Int {
        session?.cards(project, list: list) ?? 0
    }
    
    func add(_ project: Int) {
        session?.add(project, list: 0)
    }
    
    func delete(_ project: Int, list: Int, card: IndexSet) {
        session?.delete(project, list: list, card: card.first!)
        update()
    }
    
    func content(_ project: Int, list: Int, card: Int) -> String {
        session?.content(project, list: list, card: card) ?? ""
    }
    
    func move(_ project: Int, list: Int, card: Int, destination: Int, index: Int) {
        session?.move(project, list: list, card: card, destination: destination, index: index)
        update()
    }
    
    private func update() {
        loading = session == nil
        projects = session?.projects(mode) ?? []
    }
}
