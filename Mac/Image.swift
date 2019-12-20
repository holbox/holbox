import AppKit

final class Image: NSImageView {
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ name: String, tint: NSColor? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        if let tint = tint {
            image = NSImage(named: name)!.copy() as? NSImage
            image!.lockFocus()
            tint.set()
            NSRect(origin: .init(), size: image!.size).fill(using: .sourceAtop)
            image!.unlockFocus()
        } else {
            image = NSImage(named: name)
        }
        imageScaling = .scaleNone
    }
}
