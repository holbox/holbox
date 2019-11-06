import SwiftUI

final class Main: WKHostingController<AnyView> {
    override var body: AnyView { .init(Content().environmentObject(app.model)) }
    
    override func willActivate() {
        super.willActivate()
        app.refresh()
    }
}
