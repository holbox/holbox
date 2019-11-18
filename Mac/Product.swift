import AppKit

final class Product: NSView {
    private weak var shopping: Shopping?
    private weak var label: Label!
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
        layer!.cornerRadius = 8
        
        active = !app.session.contains(app.project!, reference: index)
        let product = app.session.product(app.project!, index: index)
        setAccessibilityLabel(product.1)
        
        let emoji = Label(product.0, 30, .regular, .white)
        emoji.setAccessibilityElement(false)
        addSubview(emoji)
        
        let label = Label(product.1, 11, .light, active ? .white : NSColor(named: "haze")!)
        label.setAccessibilityElement(false)
        label.maximumNumberOfLines = 2
        addSubview(label)
        self.label = label
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        emoji.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        emoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        
        label.topAnchor.constraint(equalTo: emoji.bottomAnchor, constant: 5).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -15).isActive = true

        if active {
            addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        } else {
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
            alphaValue = 0.8
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
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .clear
            if active {
                label.textColor = NSColor(named: "haze")!
            }
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if active {
            layer!.backgroundColor = NSColor(named: "haze")!.cgColor
            label.textColor = .black
        }
        super.mouseDown(with: with)
    }
    
    override func rightMouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            app.runModal(for: Stock.Edit(index))
        }
        super.rightMouseUp(with: with)
    }
    
    override func mouseUp(with: NSEvent) {
        if active {
            if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
                active = false
                let product = app.session.product(app.project!, index: index)
                app.alert(.key("Shopping.add"), message: product.0 + " " + product.1)
                app.session.add(app.project!, reference: index)
                shopping?.refresh()
                shopping?.groceryLast()
            }
            layer!.backgroundColor = .clear
            label.textColor = NSColor(named: "haze")!
        }
        super.mouseUp(with: with)
    }
}
