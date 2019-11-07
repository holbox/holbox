import holbox
import WatchKit

final class Model: ObservableObject {
    @Published var mode = Mode.off { didSet { projects = session.projects(mode) } }
    @Published var project = -1 { didSet { lists = project >= 0 ? session.lists(project) : 0 } }
    @Published var card = Index.null
    @Published private(set) var loading = true
    @Published private(set) var lists = 0
    @Published private(set) var available = 0
    @Published private(set) var projects = [Int]()
    private var session: holbox.Session!
    
    func load() {
        if session == nil {
            Session.load {
                self.session = $0
                self.available = $0.available
                self.loading = false
            }
        }
    }
    
    func refresh() {
        guard session != nil else { return }
        if session.refreshable {
            loading = true
            WKExtension.shared().rootInterfaceController!.dismiss()
            WKExtension.shared().rootInterfaceController!.popToRootController()
            card = .null
            project = -1
            mode = .off
            session.refresh {
                self.available = self.session.available
                self.loading = false
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
    
    func name(_ name: String) {
        session.name(project, name: name)
    }
    
    func content(_ card: Index, content: String) {
        session.content(project, list: card.list, card: card.index, content: content)
    }
    
    func cards(_ list: Int) -> Int {
        project >= 0 && list >= 0 ? session.cards(project, list: list) : 0
    }
    
    func delete() {
        session.delete(project)
        project = -1
        projects = session.projects(mode)
    }
    
    func delete(_ card: Index) {
        session.delete(project, list: card.list, card: card.index)
        lists = session.lists(project)
        self.card = .null
    }
    
    func move(_ card: Index, list: Int) {
        session.move(project, list: card.list, card: card.index, destination: list, index: 0)
    }
    
    func move(_ card: Index, index: Int) {
        session.move(project, list: card.list, card: card.index, destination: card.list, index: index)
    }
    
    func addProject() {
        session.add(mode)
        available = session.available
        projects = session.projects(mode)
    }
    
    func addCard() {
        session.add(project, list: 0)
        lists = session.lists(project)
    }
}
