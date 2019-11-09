import AppKit

final class Product: NSView {
    let index: Int
    private weak var shopping: Shopping?
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, _ shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        wantsLayer = true
        layer!.cornerRadius = 20
        layer!.borderColor = NSColor(named: "haze")!.cgColor
        layer!.borderWidth = 0
        alphaValue = 0.8
        
        let content = app.session.content(app.project, list: 0, card: index).components(separatedBy: "\n")
        setAccessibilityLabel(content[1].isEmpty ? content[0] : content[1])
        
        let emoji = Label(content[0], 30, .regular, .white)
        emoji.setAccessibilityElement(false)
        addSubview(emoji)
        
        let message = Label(content[1], 11, .light, NSColor(named: "haze")!)
        message.setAccessibilityElement(false)
        message.maximumNumberOfLines = 2
        message.alignment = .center
        addSubview(message)
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        emoji.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        emoji.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        message.topAnchor.constraint(equalTo: emoji.bottomAnchor, constant: 6).isActive = true
        message.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        message.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 5).isActive = true
        message.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -5).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            alphaValue = 1
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            alphaValue = 0.8
            layer!.backgroundColor = .clear
        }
    }
    
    override func mouseDown(with: NSEvent) {
        layer!.borderWidth = 2
        super.mouseDown(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            
        }
        layer!.borderWidth = 0
        super.mouseUp(with: with)
    }
}
