import AppKit

final class Control: NSView {
    weak var target: AnyObject?
    private(set) weak var label: Label!
    private let action: Selector
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ title: String, target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(title)
        wantsLayer = true
        layer!.cornerRadius = 8
        
        let label = Label(title, 14, .bold, .black)
        label.setAccessibilityElement(false)
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.3
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            _ = target?.perform(action, with: nil)
        }
        alphaValue = 1
        super.mouseUp(with: with)
    }
}
