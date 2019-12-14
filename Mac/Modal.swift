import AppKit

class Modal: Window {
    init(_ width: CGFloat, _ height: CGFloat) {
        super.init(width, height, mask: [])
        contentView!.layer!.borderColor = NSColor(named: "haze")!.withAlphaComponent(0.4).cgColor
        contentView!.layer!.borderWidth = 1
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 12:
            if with.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
                app.terminate(nil)
            } else {
                super.keyDown(with: with)
            }
        case 53: close()
        default: super.keyDown(with: with)
        }
    }
    
    override func close() {
        super.close()
        makeFirstResponder(nil)
        app.main.makeFirstResponder(app.main)
        app.stopModal()
    }
}
