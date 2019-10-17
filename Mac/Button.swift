import AppKit

final class Button: NSView {
    private weak var target: AnyObject!
    private let action: Selector
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String, target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        
        let icon = NSImageView(image: NSImage(named: image)!)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.imageScaling = .scaleNone
        addSubview(icon)
        
        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.3
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        window!.makeFirstResponder(nil)
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            _ = target.perform(action, with: nil)
        }
        alphaValue = 1
        super.mouseUp(with: with)
    }
}
