import holbox
import Foundation

final class Model: ObservableObject {
    @Published var more = false
    @Published var create = false
    @Published var mode = Mode.off
    @Published var project = -1 { didSet { relist() } }
    @Published var card = Index.null
    @Published private(set) var loading = true
    @Published private(set) var lists = 0
    var projects: [Int] { session.projects(mode) }
    private var session: holbox.Session!
    
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
                self.card = .null
                self.project = -1
                self.mode = .off
                session.refresh {
                    self.loading = false
                }
            }
        }
    }
    
    func name(_ project: Int) -> String {
        project >= 0 ? session.name(project) : ""
    }
    
    func list(_ list: Int) -> String {
        project >= 0 ? session.name(project, list: list) : ""
    }
    
    func marks(_ card: Index) -> [(String, String.Mode)] {
        let string = content(card)
        return string.mark { (.init(string[$1]), $0) }
    }
    
    func content(_ card: Index) -> String {
        project >= 0 && card != .null && card.list < lists && card.index < cards(card.list) ? session.content(project, list: card.list, card: card.index) : ""
    }
    
    func content(_ content: String) {
        session.content(project, list: card.list, card: card.index, content: content)
    }
    
    func cards(_ list: Int) -> Int {
        project >= 0 ? session.cards(project, list: list) : 0
    }
    
    func delete() {
        guard project >= 0 && card != .null else { return }
        session.delete(project, list: card.list, card: card.index)
        relist()
        card = .null
    }
    
    func move(list: Int) {
        guard project >= 0 && card != .null else { return }
        session.move(project, list: card.list, card: card.index, destination: list, index: 0)
    }
    
    private func relist() {
        lists = project >= 0 ? session.lists(project) : 0
    }
}
