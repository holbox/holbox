import SwiftUI

final class Main: WKHostingController<AnyView> {
    override var body: AnyView { .init(Content().environmentObject(app.session)) }
    
    override func willActivate() {
        super.willActivate()
        app.refresh()
    }
}
