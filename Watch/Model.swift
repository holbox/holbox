import holbox
import Foundation

final class Model: ObservableObject {
    @Published var loading = true
    @Published var more = false
    private var session: holbox.Session!
    
//    @Published var mode: Mode?
//    @Published var project: Int? { didSet { update() } }
//    @Published var item: (Int, Int)?
//    @Published var creating = false
//    @Published var more = false
//    @Published var columns = 0
//    @Published private(set) var loading = true
//    @Published private(set) var projects = [Int]()
//    @Published private(set) var position: (Int, Int)?
    
    /*var available: Int { session?.available ?? 0 }
    
    var space: Int {
        if let item = self.item {
            if position == nil {
                position = item
            }
            return cards(position!.0) + (item.0 == position!.0 ? 0 : 1)
        }
        return 0
    }
    
    var name: String {
        guard let project = self.project else { return "" }
        return name(project)
    }
    
    var content: String {
        guard let item = self.item else { return "" }
        return content(item.0, card: item.1)
    }
    */
    func load() {
        if session == nil {
            Session.load {
                self.session = $0
                self.loading = false
            }
        }
    }
    
    func refresh() {
        if let session = self.session {
            if session.refreshable {
                self.loading = true
                session.refresh {
                    self.loading = false
                }
            }
        }
    }
    /*
    func name(_ project: Int) -> String {
        session?.name(project) ?? ""
    }
    
    func name(_ name: String) {
        guard let project = self.project else { return }
        session?.name(project, name: name)
        update()
    }
    
    func add() {
        guard let mode = self.mode else { return }
        session?.add(mode)
        update()
        project = 0
        creating = false
    }
    
    func delete(_ project: IndexSet) {
        guard let session = self.session, let mode = self.mode else { return }
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
        position = (destination, 0)
    }
    
    func minus() {
        guard let item = self.item else { return }
        if position == nil {
            position = item
        }
        if position!.1 > 0 {
            position!.1 -= 1
        }
    }
    
    func plus() {
        guard let item = self.item else { return }
        if position == nil {
            position = item
        }
        if position!.1 < space - 1 {
            position!.1 += 1
        }
    }
    
    func send() {
        if let project = self.project, let item = self.item, let position = self.position {
            session?.move(project, list: item.0, card: item.1, destination: position.0, index: position.1)
        }
        item = nil
        position = nil
        update()
    }
  
    private func update() {
        loading = session == nil
        if let mode = self.mode {
            projects = session?.projects(mode) ?? []
            if let project = self.project {
                columns = session?.lists(project) ?? 0
            } else {
                columns = 0
            }
        } else {
            projects = []
            columns = 0
        }
    }*/
}
