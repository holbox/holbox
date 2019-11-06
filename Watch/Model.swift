import holbox
import Foundation

final class Model: ObservableObject {
    @Published var more = false
    @Published var create = false
    @Published var mode = Mode.off
    @Published var project = -1 { didSet { updateLists() } }
    @Published var card = -1
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
                self.card = -1
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
    
    func marks(_ list: Int, card: Int) -> [(String, String.Mode)] {
        let content = session.content(project, list: list, card: card)
        return content.mark { (.init(content[$1]), $0) }
    }
    
    func content(_ list: Int, card: Int) -> String {
        project >= 0 && card >= 0 && list < lists && card < cards(list) ? session.content(project, list: list, card: card) : ""
    }
    
    func content(_ list: Int, _ card: Int, _ content: String) {
        session.content(project, list: list, card: card, content: content)
    }
    
    func cards(_ list: Int) -> Int {
        project >= 0 ? session.cards(project, list: list) : 0
    }
    
    func delete(_ list: Int, card: Int) {
        guard project >= 0 && card >= 0 else { return }
        session.delete(project, list: list, card: card)
        updateLists()
    }
    
    private func updateLists() {
        lists = project >= 0 ? session.lists(project) : 0
    }
}
