import AppKit

final class Grocery: NSView {
    private weak var shopping: Shopping?
    private weak var emoji: Label!
    private weak var label: Label!
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
        layer!.cornerRadius = 10
//
//        let product = app.session.reference(app.project, index: index)
//        setAccessibilityLabel(product.1)
//
//        let emoji = Label(product.0, 50, .regular, .white)
//        emoji.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        emoji.setAccessibilityElement(false)
//        addSubview(emoji)
//        self.emoji = emoji
//
//        let label = Label(product.1, 16, .semibold, NSColor(named: "haze")!)
//        label.setAccessibilityElement(false)
//        label.maximumNumberOfLines = 3
//        addSubview(label)
//        self.label = label
//
//        widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
//        heightAnchor.constraint(equalToConstant: 76).isActive = true
//
//        let width = widthAnchor.constraint(equalToConstant: 500)
//        width.priority = .defaultLow
//        width.isActive = true
//
//        emoji.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        emoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
//
//        label.leftAnchor.constraint(equalTo: emoji.rightAnchor, constant: 10).isActive = true
//        label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -20).isActive = true
//        label.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
//
//        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
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
//        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
//            let product = app.session.reference(app.project, index: index)
//            app.alert(.key("Shopping.got"), message: product.0 + " " + product.1)
//            app.session.delete(app.project, list: 1, card: index)
//            shopping?.refresh()
//        }
//        alphaValue = 1
        super.mouseUp(with: with)
    }
}
