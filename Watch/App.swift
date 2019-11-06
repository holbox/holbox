import WatchKit

private(set) weak var app: App!
final class App: NSObject, WKExtensionDelegate {
    var awoke = false
    let model = Model()
    
    override init() {
        super.init()
        app = self
    }
    
    func applicationDidBecomeActive() {
        model.load()
    }
    
    func applicationDidEnterBackground() {
        awoke = true
    }
    
    func refresh() {
        if awoke {
            awoke = false
            model.refresh()
        }
    }
}
