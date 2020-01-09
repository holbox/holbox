import holbox
import WatchKit

private(set) weak var app: App!
final class App: NSObject, WKExtensionDelegate {
    var awoke = false
    let session = Session()
    
    override init() {
        super.init()
        app = self
    }
    
    func applicationDidBecomeActive() {
        if session.refreshable {
            session.refresh {
                if !$0.isEmpty {
                    WKExtension.shared().rootInterfaceController!.popToRootController()
                }
            }
        }
    }
}
