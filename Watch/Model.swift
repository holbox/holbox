import holbox
import Foundation

final class Model: ObservableObject {
    @Published var more = false
    @Published var create = false
    @Published var mode = Mode.off
    @Published private(set) var loading = true
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
                self.mode = .off
                session.refresh {
                    self.loading = false
                }
            }
        }
    }
    
    func projects(_ mode: Mode) -> [Int] {
        session.projects(mode)
    }
    
    func name(_ project: Int) -> String {
        session.name(project)
    }
}
