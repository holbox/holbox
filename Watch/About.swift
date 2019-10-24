import SwiftUI

final class About: WKHostingController<Rectangle> {
    override var body: Rectangle { Rectangle() }
    
    override func didAppear() {
        super.didAppear()
        app.global.mode = .off
        app.global.project = nil
    }
}
