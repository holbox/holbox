import AppKit

final class Item: NSView {
    var selected = false { didSet { update() } }
    let index: Int
    private weak var label: Label!
    private weak var target: AnyObject!
    private weak var base: NSView!
    private let action: Selector
    private let color: NSColor
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ title: String, index: Int, _ font: NSFont.Weight, _ size: CGFloat, _ color: NSColor, _ target: AnyObject, _ action: Selector) {
        self.index = index
        self.action = action
        self.target = target
        self.color = color
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(title)
        wantsLayer = true
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 8
        addSubview(base)
        self.base = base
        
        let label = Label(title, size, font, color)
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseDown(with: NSEvent) {
        selected = true
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            _ = target.perform(action, with: self)
        }
        selected = false
        super.mouseUp(with: with)
    }
    
    private func update() {
        base.layer!.backgroundColor = selected ? NSColor(named: "haze")!.cgColor : .clear
        label.textColor = selected ? .black : color
    }
}
