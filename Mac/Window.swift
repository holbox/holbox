import AppKit

class Window: NSWindow {
    override var canBecomeKey: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    init(_ width: CGFloat, _ height: CGFloat, mask: NSWindow.StyleMask) {
        super.init(contentRect: .init(x: 0, y: 0, width: width, height: height), styleMask: [.borderless, mask], backing: .buffered, defer: false)
        appearance = NSAppearance(named: .darkAqua)
        backgroundColor = .clear
        isOpaque = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.cornerRadius = 10
    }
    
    override func becomeKey() {
        super.becomeKey()
        hasShadow = true
        contentView!.subviews.forEach { $0.alphaValue = 1 }
    }
    
    override func resignKey() {
        super.resignKey()
        hasShadow = false
        contentView!.subviews.forEach { $0.alphaValue = 0.4 }
    }
}
