import UIKit

@UIApplicationMain final class App: UIViewController, UIApplicationDelegate {
    private(set) var win: UIWindow!
    func application(_ a: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        win = UIWindow()
        win.rootViewController = self
        win.backgroundColor = .background
        win.makeKeyAndVisible()
        return true
    }
}
