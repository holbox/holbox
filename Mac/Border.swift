import AppKit

final class Border: NSView {
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.backgroundColor = .black
        
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
