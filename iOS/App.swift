import holbox
import UIKit
import StoreKit

private(set) weak var app: App!
@UIApplicationMain final class App: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var project = 0
    var mode = Mode.off
    private(set) weak var main: Main!
    private(set) var session: Session!
    private(set) var win: UIWindow!
    
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        app = self
        
        win = UIWindow()
        if #available(iOS 13.0, *) {
            win.overrideUserInterfaceStyle = .dark
        }
        win.rootViewController = self
        win.backgroundColor = .black
        win.makeKeyAndVisible()
        return true
    }
    
    func applicationWillEnterForeground(_: UIApplication) {
        refresh()
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        UNUserNotificationCenter.current().getDeliveredNotifications { UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0.map { $0.request.identifier
        }.filter { $0 != willPresent.request.identifier }) }
    }
    
    override func loadView() {
        view = Main()
        main = view as? Main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getNotificationSettings {
            if $0.authorizationStatus != .authorized {
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 20) {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
                }
            }
        }
        
        Session.load {
            self.session = $0
            if self.session.rate {
                SKStoreReviewController.requestReview()
                self.session.rated()
            }
            self.main.loaded()
        }
    }
    
    func alert(_ title: String, message: String) {
        UNUserNotificationCenter.current().getNotificationSettings {
            if $0.authorizationStatus == .authorized {
                UNUserNotificationCenter.current().add({
                    $0.title = title
                    $0.body = message
                    return .init(identifier: UUID().uuidString, content: $0, trigger: nil)
                } (UNMutableNotificationContent()))
            } else {
                DispatchQueue.main.async {
                    let alert = Alert(title, message: message)
                    self.main.addSubview(alert)
                    
                    alert.topAnchor.constraint(equalTo: self.main.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
                    alert.leftAnchor.constraint(equalTo: self.main.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
                    alert.rightAnchor.constraint(equalTo: self.main.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
                }
            }
        }
    }
    
    func refresh() {
        if session?.refreshable == true {
            win.endEditing(true)
            dismiss(animated: false)
            DispatchQueue.main.async {
                self.session?.refresh {
                    self.main.base?.refresh()
                }
            }
        }
    }
}
