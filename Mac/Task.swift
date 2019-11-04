import AppKit

final class Task: NSView {
    var highlighted = false { didSet { update() } }
    let index: Int
    let selected: Bool
    private weak var label: Label!
    private weak var icon: Image!
    private weak var target: AnyObject!
    private weak var circle: NSView!
    private let action: Selector
    override var mouseDownCanMoveWindow: Bool { false }
    private var active: Bool { (selected && !highlighted) || (!selected && highlighted) }
    
    required init?(coder: NSCoder) { nil }
    init(_ content: String, index: Int, selected: Bool, _ target: AnyObject, _ action: Selector) {
        self.index = index
        self.selected = selected
        self.action = action
        self.target = target
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(content)
        wantsLayer = true
        layer!.cornerRadius = 12
        
        let circle = NSView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.wantsLayer = true
        circle.layer!.cornerRadius = 15
        circle.layer!.borderColor = .black
        circle.layer!.borderWidth = 2
        addSubview(circle)
        self.circle = circle
        
        let icon = Image("check")
        addSubview(icon)
        self.icon = icon
        
        let label = Label(content, 16, .medium, .white)
        addSubview(label)
        self.label = label
        
        bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor, constant: 20).isActive = true
        
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 30).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 1).isActive = true
        
        label.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        update()
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseDown(with: NSEvent) {
        highlighted = true
        super.mouseDown(with: with)
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .clear
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            _ = target.perform(action, with: self)
        }
        highlighted = false
        super.mouseUp(with: with)
    }
    
    private func update() {
        icon.isHidden = !active
        circle.layer!.backgroundColor = active ? NSColor(named: "haze")!.cgColor : NSColor(named: "background")!.cgColor
        label.textColor = active ? NSColor(named: "haze")! : .white
    }
}
