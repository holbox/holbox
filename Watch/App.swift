import holbox
import WatchKit

private(set) weak var app: App!
final class App: NSObject, WKExtensionDelegate {
    let global = Global()
    
    override init() {
        super.init()
        app = self
    }
    
    func applicationDidBecomeActive() {
        if global.session == nil {
            Session.load {
                self.global.session = $0
            }
        }
    }
}

final class Global: ObservableObject {
    @Published var session: Session!
    var mode = Mode.off
    var project = 0
}
