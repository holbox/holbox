import AppKit

final class Tab: NSView {
    var selected = false { didSet { update() } }
    private weak var icon: Image!
    private weak var target: AnyObject!
    private let action: Selector
    private let image: NSImage
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String, target: AnyObject, action: Selector) {
        self.image = NSImage(named: image)!
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
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
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            app.main.makeFirstResponder(self)
            _ = target.perform(action, with: nil)
        }
        super.mouseUp(with: with)
    }
    
    private func update() {
        layer!.backgroundColor = selected ? .haze : .clear
        icon.image = selected ? image.tint(.black) : image
        icon.alphaValue = selected ? 1 : 0.4
    }
}
