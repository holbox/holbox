import AppKit

final class Control: NSView {
    private weak var target: AnyObject!
    private let action: Selector
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ title: String, _ target: AnyObject, _ action: Selector, _ background: CGColor, _ text: NSColor) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(title)
        wantsLayer = true
        layer!.cornerRadius = 6
        layer!.backgroundColor = background
        
        let label = Label(title, .medium(12), text)
        label.setAccessibilityElement(false)
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseExited(with: NSEvent) {
        alphaValue = 1
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.3
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            _ = target.perform(action, with: nil)
        } else {
            super.mouseUp(with: with)
        }
        alphaValue = 1
    }
}
