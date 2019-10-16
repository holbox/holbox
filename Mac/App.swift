import holbox
import AppKit
import StoreKit
import UserNotifications

private(set) weak var app: App!
@NSApplicationMain final class App: NSApplication, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSTouchBarDelegate {
    var project = 0
    var mode = Mode.off
    private(set) var session: Session!
    private(set) weak var main: Main!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        app = self
        delegate = self
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { true }
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert])
        UNUserNotificationCenter.current().getDeliveredNotifications { UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0.map { $0.request.identifier
        }.filter { $0 != willPresent.request.identifier }) }
    }
    
//    override func makeTouchBar() -> NSTouchBar? {
//        let bar = NSTouchBar()
//        bar.delegate = self
//        bar.defaultItemIdentifiers = [.init("Options")]
//        return bar
//    }
//
//    func touchBar(_: NSTouchBar, makeItemForIdentifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
//        let item = NSCustomTouchBarItem(identifier: makeItemForIdentifier)
//        let button = NSButton(title: "", target: self, action: nil)
//        item.view = button
//        button.title = .key(makeItemForIdentifier.rawValue)
//        switch makeItemForIdentifier.rawValue {
//        case "Options": button.action = #selector(about)
//        default: break
//        }
//        return item
//    }
    
    func applicationWillFinishLaunching(_: Notification) {
        mainMenu = Menu()
        
        let _main = Main()
        _main.makeKeyAndOrderFront(nil)
        main = _main
        
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
                DispatchQueue.main.async { Alert(title, message: message).makeKeyAndOrderFront(nil) }
            }
        }
    }
}
