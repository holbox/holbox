import UIKit

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate {
    private(set) weak var main: Main!
    private(set) var win: UIWindow!
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        app = self
        
        win = UIWindow()
        win.rootViewController = self
        win.backgroundColor = .background
        win.makeKeyAndVisible()
        return true
    }
    
    override func loadView() {
        view = Main()
        main = view as? Main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        main.loaded()
    }
}
