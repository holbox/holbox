import AppKit

final class Tool: NSView {
    private weak var icon: Image!
    private let action: Selector
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ image: String, action: Selector) {
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        alphaValue = 0.8
        
        let icon = Image(image)
        icon.alphaValue = 0.5
        addSubview(icon)
        self.icon = icon
        
        widthAnchor.constraint(equalToConstant: 12).isActive = true
        heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        icon.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        icon.topAnchor.constraint(equalTo: topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        icon.alphaValue = 1
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        icon.alphaValue = 0.5
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 1
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            _ = window!.perform(action, with: nil)
        }
        alphaValue = 0.8
        super.mouseUp(with: with)
    }
}
