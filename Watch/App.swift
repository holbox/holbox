import WatchKit
import SwiftUI

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
        refresh()
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

final class Main: WKHostingController<AnyView> {
    override var body: AnyView { .init(Content().environmentObject(app.model)) }
}
