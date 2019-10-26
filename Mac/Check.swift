import AppKit

final class Check: NSView {
    var on = false { didSet { update() } }
    private weak var target: AnyObject!
    private weak var icon: Image!
    private weak var circle: NSView!
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
        
        let circle = NSView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.wantsLayer = true
        circle.layer!.cornerRadius = 15
        addSubview(circle)
        self.circle = circle
        
        let label = Label(text, 14, .medium, .init(white: 1, alpha: 0.9))
        label.setAccessibilityElement(false)
        addSubview(label)
        
        let icon = Image("check")
        addSubview(icon)
        self.icon = icon
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        widthAnchor.constraint(equalToConstant: 180).isActive = true
        
        circle.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 30).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 1).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        
        update()
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.4
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        window!.makeFirstResponder(nil)
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            on.toggle()
            _ = target.perform(action, with: self)
        }
        alphaValue = 1
        super.mouseUp(with: with)
    }
    
    private func update() {
        icon.isHidden = !on
        circle.layer!.backgroundColor = on ? NSColor(named: "haze")!.cgColor : NSColor(white: 0, alpha: 0.3).cgColor
    }
}
