import AppKit

final class Border: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.4).cgColor
        
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
