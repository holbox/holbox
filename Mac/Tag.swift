import AppKit

final class Tag: NSView {
    private let name: String
    
    required init?(coder: NSCoder) { nil }
    init(_ name: String, count: Int) {
        self.name = name
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        
        let label = Label([("\(count)", 13, .medium, NSColor(named: "haze")!),
                           (" #" + name, 14, .bold, NSColor(named: "haze")!)])
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setAccessibilityLabel(label.stringValue)
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 34).isActive = true
        rightAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.3
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            app.main.bar.find.search("#"+name)
        }
        alphaValue = 1
        super.mouseUp(with: with)
    }
}
