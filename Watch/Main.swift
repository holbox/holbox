import SwiftUI

final class Main: WKHostingController<AnyView> {
    override var body: AnyView { .init(Detail(global: app.global)) }
    
    override func didAppear() {
        super.didAppear()
        app.global.mode = .kanban
        app.refresh()
    }
}
