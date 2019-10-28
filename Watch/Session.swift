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
        if session?.refreshable == true {
            session?.refresh {
                self.update()
            }
        }
    }
    
    func name(_ project: Int) -> String { session?.name(project) ?? "" }
    
    func add() {
        session?.add(mode)
        update()
    }
    
    func delete(_ project: IndexSet) {
        guard let session = self.session else { return }
        session.delete(session.projects(mode)[project.first!])
        update()
    }
    
    private func update() {
        loading = session == nil
        projects = session?.projects(mode) ?? []
    }
}
