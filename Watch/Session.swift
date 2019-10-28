import holbox
import Foundation

final class Session: ObservableObject {
    @Published private(set) var loading = true
    @Published private(set) var projects = [Int]()
    @Published private(set) var columns = 0
    @Published var project: Int? { didSet { update() } }
    @Published var item: (Int, Int)?
    @Published var creating = false
    var session: holbox.Session? { didSet { update() } }
    var available: Int { session?.available ?? 0 }
    let mode = Mode.kanban
    
    var cards: Int {
        guard let item = self.item else { return 0 }
        return cards(item.0)
    }
    
    var name: String {
        guard let project = self.project else { return "" }
        return name(project)
    }
    
    var content: String {
        guard let item = self.item else { return "" }
        return content(item.0, card: item.1)
    }
    
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
    
    func name(_ name: String) {
        guard let project = self.project else { return }
        session?.name(project, name: name)
        update()
    }
    
    func add() {
        session?.add(mode)
        update()
        project = 0
        creating = false
    }
    
    func delete(_ project: IndexSet) {
        guard let session = self.session else { return }
        session.delete(session.projects(mode)[project.first!])
        update()
    }
    
    func list(_ list: Int) -> String {
        guard let project = self.project else { return "" }
        return session?.name(project, list: list) ?? ""
    }
    
    func cards(_ list: Int) -> Int {
        guard let project = self.project else { return 0 }
        return session?.cards(project, list: list) ?? 0
    }
    
    func card() {
        guard let project = self.project else { return }
        session?.add(project, list: 0)
        item = (0, 0)
    }
    
    func delete(_ list: Int, card: IndexSet) {
        guard let project = self.project else { return }
        session?.delete(project, list: list, card: card.first!)
        update()
    }
    
    func content(_ list: Int, card: Int) -> String {
        guard let project = self.project else { return "" }
        if cards(list) > card {
            return session?.content(project, list: list, card: card) ?? ""
        }
        return ""
    }
    
    func content(_ content: String) {
        guard let project = self.project, let item = self.item else { return }
        session?.content(project, list: item.0, card: item.1, content: content)
        self.item = item
    }
    
    func move(_ destination: Int) {
        guard let project = self.project, let item = self.item else { return }
        session?.move(project, list: item.0, card: item.1, destination: destination, index: 0)
        self.item = nil
        update()
    }
    
    func minus() {
        guard let project = self.project, let item = self.item else { return }
        if item.1 > 0 {
            session?.move(project, list: item.0, card: item.1, destination: item.0, index: item.1 - 1)
            self.item = nil
            update()
        }
    }
    
    func plus() {
        guard let project = self.project, let item = self.item else { return }
        if item.1 < cards - 1 {
            session?.move(project, list: item.0, card: item.1, destination: item.0, index: item.1 + 1)
            self.item = nil
            update()
        }
    }
    
    private func update() {
        loading = session == nil
        projects = session?.projects(mode) ?? []
        if let project = self.project {
            columns = session?.lists(project) ?? 0
        } else {
            columns = 0
        }
    }
}
