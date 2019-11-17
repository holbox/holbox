import AppKit

final class Border: NSView {
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
        
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
