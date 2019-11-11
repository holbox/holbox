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
            WKExtension.shared().rootInterfaceController!.dismissTextInputController()
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
        return string.mark { ({
            $0.first == "\n" ? .init($0.dropFirst()) : .init($0)
        } (string[$1]), $0) }
    }
    
    func content(_ card: Index) -> String {
        project >= 0 && card != .null && card.list < session.lists(project) && card.index < session.cards(project, list: card.list)
            ? session.content(project, list: card.list, card: card.index)
            : ""
    }
    
    func product(_ index: Int) -> (String, String) {
        project >= 0 && session.lists(project) > 0 && index < session.cards(project, list: 0)
            ? session.product(project, index: index)
            : ("", "")
    }
    
    func reference(_ index: Int) -> (String, String) {
        project >= 0 && session.lists(project) > 1 && index < session.cards(project, list: 1)
            ? session.reference(project, index: index)
            : ("", "")
    }
    
    func active(_ index: Int) -> Bool {
        project >= 0 && session.lists(project) > 0 && index < session.cards(project, list: 0)
            ? session.contains(project, reference: index)
            : false
    }
    
    func name(_ name: String) {
        session.name(project, name: name)
    }
    
    func content(_ card: Index, content: String) {
        session.content(project, list: card.list, card: card.index, content: content)
    }
    
    func product(_ index: Int, emoji: String, description: String) {
        session.product(project, index: index, emoji: emoji, description: description)
        lists = session.lists(project)
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
    
    func delete(_ product: Int) {
        session.delete(project, product: product)
        lists = session.lists(project)
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
    
    func addTask(_ content: String) {
        session.add(project, list: 0, content: content)
        lists = session.lists(project)
    }
    
    func addProduct(_ emoji: String, description: String) {
        session.add(project, emoji: emoji, description: description)
        lists = session.lists(project)
    }
    
    func addReference(_ index: Int) {
        session.add(project, reference: index)
        lists = session.lists(project)
    }
}
