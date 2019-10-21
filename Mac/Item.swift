import AppKit

final class Item: NSView {
    let index: Int
    private weak var label: Label!
    private weak var target: AnyObject!
    private let action: Selector
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ title: String, index: Int, _ target: AnyObject, _ action: Selector) {
        self.index = index
        self.action = action
        self.target = target
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(title)
        wantsLayer = true
        layer!.cornerRadius = 8
        
        let label = Label(title, 16, .bold, .white)
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseDown(with: NSEvent) {
        layer!.backgroundColor = .haze
        label.textColor = .black
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            _ = target.perform(action, with: self)
        } else {
            layer!.backgroundColor = .clear
            label.textColor = .white
        }
        super.mouseUp(with: with)
    }
}
