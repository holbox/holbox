import AppKit

final class Product: NSView {
    let index: Int
    private(set) weak var text: Text!
    private weak var shopping: Shopping?
    private let active: Bool
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, _ shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        active = !app.session.contains(app.project!, reference: index)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        wantsLayer = true
        layer!.cornerRadius = 10
        layer!.borderColor = NSColor(named: "haze")!.cgColor
        layer!.borderWidth = 0
        
        let product = app.session.product(app.project!, index: index)
        setAccessibilityLabel(product.1)
        
        let text = Text(.Fix(), Off())
        text.textContainerInset.width = 10
        text.textContainerInset.height = 10
        text.setAccessibilityElement(false)
        if active {
            (text.textStorage as! Storage).fonts = [
                .plain: (.systemFont(ofSize: 12, weight: .medium), .white),
                .emoji: (NSFont(name: "Times New Roman", size: 18)!, .white),
                .bold: (.systemFont(ofSize: 14, weight: .bold), NSColor(named: "haze")!),
                .tag: (.systemFont(ofSize: 12, weight: .bold), NSColor(named: "haze")!)]
        } else {
            (text.textStorage as! Storage).fonts = [
                .plain: (.systemFont(ofSize: 12, weight: .medium), .init(white: 1, alpha: 0.6)),
                .emoji: (NSFont(name: "Times New Roman", size: 18)!, .white),
                .bold: (.systemFont(ofSize: 14, weight: .bold), .init(white: 1, alpha: 0.6)),
                .tag: (.systemFont(ofSize: 12, weight: .bold), .init(white: 1, alpha: 0.6))]
        }
        (text.layoutManager as! Layout).owns = true
        (text.layoutManager as! Layout).padding = 0
        text.textContainer!.maximumNumberOfLines = 3
        text.string = product.0 + " " + product.1
        addSubview(text)
        self.text = text
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        widthAnchor.constraint(equalToConstant: 110).isActive = true
        
        text.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        text.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true

        if active {
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
            addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        } else {
            alphaValue = 0.6
        }
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        layer!.borderWidth = 2
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        layer!.borderWidth = 0
    }
    
    override func mouseDown(with: NSEvent) {
        if active {
            alphaValue = 0.3
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
                let product = app.session.product(app.project!, index: index)
                app.alert(.key("Shopping.add"), message: product.0 + " " + product.1)
                app.session.add(app.project!, reference: index)
                shopping?.refresh()
                shopping?.groceryLast()
            }
            alphaValue = 1
        }
        super.mouseUp(with: with)
    }
}
