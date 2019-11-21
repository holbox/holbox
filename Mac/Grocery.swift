import AppKit

final class Grocery: NSView {
    let index: Int
    private(set) weak var text: Text!
    private weak var emoji: Label!
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        wantsLayer = true
        layer!.cornerRadius = 10

        let product = app.session.reference(app.project!, index: index)
        setAccessibilityLabel(product.1)

        let emoji = Label(product.0, 35, .regular, .white)
        emoji.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        emoji.setAccessibilityElement(false)
        addSubview(emoji)
        self.emoji = emoji
        
        let text = Text(.Fixed(), Off())
        text.setAccessibilityElement(false)
        (text.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: 14, weight: .medium), .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: 14)!, .white),
                                               .bold: (.systemFont(ofSize: 16, weight: .bold), NSColor(named: "haze")!),
                                               .tag: (.systemFont(ofSize: 14, weight: .bold), NSColor(named: "haze")!)]
        (text.layoutManager as! Layout).owns = true
        text.string = product.1
        addSubview(text)
        addSubview(text)
        self.text = text

        widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        bottomAnchor.constraint(equalTo: text.bottomAnchor).isActive = true

        let width = widthAnchor.constraint(equalToConstant: 500)
        width.priority = .defaultLow
        width.isActive = true

        emoji.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        emoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true

        text.leftAnchor.constraint(equalTo: emoji.rightAnchor).isActive = true
        text.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -5).isActive = true
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true

        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseDown(with: NSEvent) {
        alphaValue = 0.5
        super.mouseDown(with: with)
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .clear
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            let product = app.session.reference(app.project!, index: index)
            app.alert(.key("Shopping.got"), message: product.0 + " " + product.1)
            app.session.delete(app.project!, list: 1, card: index)
            app.main.refresh()
        }
        alphaValue = 1
        super.mouseUp(with: with)
    }
}
