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
        print("awoke")
        session.load()
    }
    
    func applicationDidEnterBackground() {
        awoke = true
    }
    
    func refresh() {
        if awoke {
            awoke = false
            session.refresh()
        }
    }
}
