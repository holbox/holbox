import AppKit

final class Image: NSImageView {
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ name: String) {
        super.init(frame: .zero)
        image = NSImage(named: name)
        translatesAutoresizingMaskIntoConstraints = false
        imageScaling = .scaleNone
    }
}
