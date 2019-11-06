import holbox
import Foundation

final class Model: ObservableObject {
    @Published var more = false
    @Published var create = false
    @Published var mode = Mode.off
    @Published var project = -1
    @Published var card = -1
    @Published private(set) var loading = true
    var projects: [Int] { session.projects(mode) }
    var lists: Int { project >= 0 ? session.lists(project) : 0 }
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
    
    func content(_ list: Int, card: Int) -> String {
        project >= 0 ? session.content(project, list: list, card: card) : ""
    }
    
    func cards(_ list: Int) -> Int {
        project >= 0 ? session.cards(project, list: list) : 0
    }
    
}
