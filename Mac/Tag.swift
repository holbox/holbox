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
        setAccessibilityLabel("\(count) #" + name)
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.backgroundColor = NSColor(named: "haze")!.cgColor
        base.layer!.cornerRadius = 4
        addSubview(base)
        
        let label = Label("#" + name, 12, .medium, .black)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setAccessibilityElement(false)
        addSubview(label)
        
        let _count = Label("\(count)", 12, .regular, NSColor(named: "haze")!)
        _count.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        _count.setAccessibilityElement(false)
        addSubview(_count)
        
        bottomAnchor.constraint(equalTo: base.bottomAnchor, constant: 3).isActive = true
        rightAnchor.constraint(equalTo: _count.rightAnchor, constant: 5).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 2).isActive = true
        base.rightAnchor.constraint(equalTo: label.rightAnchor, constant: 4).isActive = true
        
        label.leftAnchor.constraint(equalTo: base.leftAnchor, constant: 4).isActive = true
        label.topAnchor.constraint(equalTo: base.topAnchor, constant: 2).isActive = true
        
        _count.centerYAnchor.constraint(equalTo: base.centerYAnchor).isActive = true
        _count.leftAnchor.constraint(equalTo: base.rightAnchor, constant: 3).isActive = true
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.3
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            app.main.bar.find.search("#"+name)
        }
        alphaValue = 1
    }
}
