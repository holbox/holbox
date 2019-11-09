import AppKit

final class Product: NSView {
    private weak var shopping: Shopping?
    private weak var message: Label!
    private var active = true
    private let index: Int
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
        
        active = !app.session.contains(app.project, reference: index)
        let product = app.session.product(app.project, index: index)
        layer!.borderWidth = active ? 0 : 1
        layer!.borderColor = active ? NSColor(named: "haze")!.cgColor : NSColor(named: "background")!.cgColor
        setAccessibilityLabel(product.1)
        
        let emoji = Label(product.0, 30, .regular, .white)
        emoji.setAccessibilityElement(false)
        emoji.alphaValue = active ? 1 : 0.4
        addSubview(emoji)
        
        let message = Label(product.1, 11, .light, NSColor(named: "haze")!)
        message.setAccessibilityElement(false)
        message.maximumNumberOfLines = 2
        message.alignment = .center
        message.alphaValue = active ? 1 : 0.8
        addSubview(message)
        self.message = message
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        emoji.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        emoji.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        message.topAnchor.constraint(equalTo: emoji.bottomAnchor, constant: 6).isActive = true
        message.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        message.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 5).isActive = true
        message.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -5).isActive = true

        if active {
            addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        }
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
            message.textColor = .white
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .clear
            message.textColor = NSColor(named: "haze")!
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if active {
            layer!.borderWidth = 2
        }
        super.mouseDown(with: with)
    }
    
    override func rightMouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) {
            guard let shopping = self.shopping else { return }
            app.runModal(for: Stock.Edit(shopping, index: index))
        }
        super.rightMouseUp(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if active {
            if bounds.contains(convert(with.locationInWindow, from: nil)) {
                active = false
                app.session.add(app.project, reference: index)
                shopping?.refresh()
                shopping?.groceryLast()
            }
            layer!.borderWidth = 0
        }
        super.mouseUp(with: with)
    }
}
