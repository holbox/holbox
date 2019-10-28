import SwiftUI

final class Main: WKHostingController<AnyView> {
    override var body: AnyView { .init(Detail().environmentObject(app.global)) }
    
    override func willActivate() {
        super.willActivate()
        app.global.mode = .kanban
        app.refresh()
    }
}
