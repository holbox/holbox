import SwiftUI

final class Kanban: WKHostingController<AnyView> {
    override var body: AnyView { .init(Detail().environmentObject(app.global)) }
    
    override func didAppear() {
        super.didAppear()
        app.global.mode = .kanban
    }
}
