import WatchKit
import SwiftUI

final class App: WKHostingController<Circle> {
    override var body: Circle {
        Circle()
    }
    
    override func awake(withContext: Any?) {
        super.awake(withContext: withContext)
        
    }
}
