import AppKit

class Option: NSView {
    final class Item: Option {
        private let index: Int
        
        required init?(coder: NSCoder) { nil }
        init(_ index: Int, settings: Settings) {
            self.index = index
            super.init(settings, title: .key("Settings.options.\(index)"))
        }
        
        override func click() {
            settings?.option(index)
        }
    }

    final class Check: Option {
        var on = false {
            didSet {
                circle.layer!.backgroundColor = on ? .haze() : .clear
                check.alphaValue = on ? 1 : 0
            }
        }
        
        private weak var circle: NSView!
        private weak var check: Image!
        override func accessibilityValue() -> Any? { on }
        
        required init?(coder: NSCoder) { nil }
        init(_ title: String, settings: Settings) {
            super.init(settings, title: title)
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.cornerRadius = 11
            circle.layer!.borderWidth = 2
            circle.layer!.borderColor = .haze()
            addSubview(circle)
            self.circle = circle
            
            let check = Image("check")
            addSubview(check)
            self.check = check
            
            circle.widthAnchor.constraint(equalToConstant: 22).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 22).isActive = true
            circle.centerYAnchor.constraint(lessThanOrEqualTo: centerYAnchor).isActive = true
            circle.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
            
            check.widthAnchor.constraint(equalToConstant: 14).isActive = true
            check.heightAnchor.constraint(equalToConstant: 14).isActive = true
            check.centerYAnchor.constraint(lessThanOrEqualTo: circle.centerYAnchor, constant: 1).isActive = true
            check.centerXAnchor.constraint(lessThanOrEqualTo: circle.centerXAnchor).isActive = true
        }
        
        override func click() {
            settings?.check(self)
        }
    }
    
    private weak var settings: Settings?
    
    required init?(coder: NSCoder) { nil }
    init(_ settings: Settings, title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityLabel(title)
        setAccessibilityRole(.button)
        wantsLayer = true
        layer!.cornerRadius = 4
        self.settings = settings
        
        let label = Label(title, .regular(12), .haze())
        addSubview(label)
        
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        widthAnchor.constraint(equalToConstant: 340).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseEntered(with: NSEvent) {
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.4
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .haze(0.3)
        }
    }
    
    override func mouseExited(with: NSEvent) {
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .clear
        }
    }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.4
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            click()
        }
        alphaValue = 1
    }
    
    func click() { }
}
