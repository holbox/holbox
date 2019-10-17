import AppKit

final class Check: NSView {
    var on = false { didSet { update() }}
    private weak var target: AnyObject!
    private weak var icon: Image!
    private weak var label: Label!
    private let action: Selector
    override var mouseDownCanMoveWindow: Bool { false }
    override func accessibilityValue() -> Any? { on }
    
    required init?(coder: NSCoder) { nil }
    init(_ text: String, target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.checkBox)
        setAccessibilityLabel(text)
        wantsLayer = true
        layer!.cornerRadius = 4
        
        let label = Label(text, 14, .regular, .black)
        label.setAccessibilityElement(false)
        addSubview(label)
        self.label = label
        
        let icon = Image("check")
        addSubview(icon)
        self.icon = icon
        
        heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        icon.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        icon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: icon.leftAnchor, constant: -10).isActive = true
        
        update()
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseUp(with: NSEvent) {
        window!.makeFirstResponder(nil)
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            on.toggle()
            _ = target.perform(action, with: self)
        }
        super.mouseUp(with: with)
    }
    
    private func update() {
        icon.isHidden = !on
        label.textColor = on ? .black : .init(white: 1, alpha: 0.5)
        layer!.backgroundColor = on ? .haze : NSColor(white: 1, alpha: 0.05).cgColor
    }
}
