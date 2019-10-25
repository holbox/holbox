import AppKit

class Modal: Window {
    init(_ width: CGFloat, _ height: CGFloat) {
        super.init(width, height, mask: [])
        _close.isHidden = true
        _minimise.isHidden = true
        _zoom.isHidden = true
        contentView!.layer!.backgroundColor = NSColor(named: "background")!.cgColor
    }
    
    override func becomeKey() {
        super.becomeKey()
        contentView!.layer!.backgroundColor = NSColor(named: "background")!.cgColor
    }
    
    override func resignKey() {
        super.resignKey()
        contentView!.layer!.backgroundColor = .black
    }
    
    override func keyDown(with: NSEvent) {
        switch with.keyCode {
        case 53: close()
        default: super.keyDown(with: with)
        }
    }
    
    override func close() {
        super.close()
        app.stopModal()
    }
}
