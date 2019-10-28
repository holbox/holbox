import SwiftUI

final class Main: WKHostingController<AnyView> {
    override var body: AnyView { .init(Detail().environmentObject(app.session)) }
    
    override func willActivate() {
        super.willActivate()
        app.refresh()
    }
}
