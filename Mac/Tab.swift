import AppKit

final class Tab: NSView {
    var selected = false { didSet { update() } }
    private weak var icon: Image!
    private let action: (Tab) -> Void
    private let image: NSImage
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String, label: String, action: @escaping (Tab) -> Void) {
        self.image = NSImage(named: image)!
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(label)
        wantsLayer = true
        layer!.cornerRadius = 4
        
        let icon = Image(image)
        addSubview(icon)
        self.icon = icon
        
        widthAnchor.constraint(equalToConstant: 30).isActive = true
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        update()
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseUp(with: NSEvent) {
        if !selected && bounds.contains(convert(with.locationInWindow, from: nil)) {
            app.main.makeFirstResponder(self)
            action(self)
        }
        super.mouseUp(with: with)
    }
    
    private func update() {
        icon.image = selected ? image.tint(.black) : image
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            icon.alphaValue = selected ? 1 : 0.5
            layer!.backgroundColor = selected ? NSColor(named: "haze")!.cgColor : .clear
        }
    }
}
