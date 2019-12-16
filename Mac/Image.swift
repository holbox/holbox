import AppKit

final class Image: NSImageView {
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ name: String, tint: NSColor? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        if let tint = tint {
            image = NSImage(named: name)!.tint(tint)
        } else {
            image = NSImage(named: name)
        }
        imageScaling = .scaleNone
    }
}
