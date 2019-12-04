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
        refresh()
    }
    
    func applicationDidEnterBackground() {
        awoke = true
    }
    
    func refresh() {
        if awoke {
            awoke = false
            if session.refreshable {
                WKExtension.shared().rootInterfaceController!.dismissTextInputController()
                session.refresh {
                    if !$0.isEmpty {
                        WKExtension.shared().rootInterfaceController!.dismiss()
                        WKExtension.shared().rootInterfaceController!.popToRootController()
                    }
                }
            }
        }
    }
}
