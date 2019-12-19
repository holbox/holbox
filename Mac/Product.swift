import AppKit

final class Product: NSView {
    let index: Int
    private(set) weak var text: Text!
    private weak var shopping: Shopping!
    private let active: Bool
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, _ shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        active = !app.session.contains(app.project, reference: index)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        wantsLayer = true
        layer!.cornerRadius = 10
        
        let product = app.session.product(app.project, index: index)
        setAccessibilityLabel(product.1)
        
        let text = Text(.Fix(), Off(), storage: .init())
        text.textContainerInset.width = 20
        text.textContainerInset.height = 20
        text.setAccessibilityElement(false)
//        if active {
//            (text.textStorage as! Storage).fonts = [
//                .plain: (.systemFont(ofSize: 12, weight: .medium), .white),
//                .emoji: (NSFont(name: "Times New Roman", size: 18)!, .white),
//                .bold: (.systemFont(ofSize: 14, weight: .bold), NSColor(named: "haze")!),
//                .tag: (.systemFont(ofSize: 12, weight: .bold), NSColor(named: "haze")!)]
//        } else {
//            (text.textStorage as! Storage).fonts = [
//                .plain: (.systemFont(ofSize: 12, weight: .medium), .init(white: 1, alpha: 0.7)),
//                .emoji: (NSFont(name: "Times New Roman", size: 18)!, .white),
//                .bold: (.systemFont(ofSize: 14, weight: .bold), .init(white: 1, alpha: 0.5)),
//                .tag: (.systemFont(ofSize: 12, weight: .bold), .init(white: 1, alpha: 0.5))]
//        }
        (text.layoutManager as! Layout).owns = true
        (text.layoutManager as! Layout).padding = 0
        text.textContainer!.maximumNumberOfLines = 3
        text.string = product.0 + " " + product.1
        addSubview(text)
        self.text = text
        
        heightAnchor.constraint(equalToConstant: 120).isActive = true
        widthAnchor.constraint(equalToConstant: 130).isActive = true
        
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        if active {
            let circle = NSView()
            circle.translatesAutoresizingMaskIntoConstraints = false
            circle.wantsLayer = true
            circle.layer!.cornerRadius = 11
            circle.layer!.backgroundColor = NSColor(named: "haze")!.cgColor
            addSubview(circle)
            
            let icon = Image("check")
            addSubview(icon)
            
            circle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
            circle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            circle.widthAnchor.constraint(equalToConstant: 22).isActive = true
            circle.heightAnchor.constraint(equalToConstant: 22).isActive = true
            
            icon.widthAnchor.constraint(equalToConstant: 14).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 14).isActive = true
            icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
            icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
            
            addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        } else {
            alphaValue = 0.6
        }
    }
    
    override func resetCursorRects() {
        if active {
            addCursorRect(bounds, cursor: .pointingHand)
        }
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        layer!.backgroundColor = NSColor(named: "background")!.cgColor
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        layer!.backgroundColor = .clear
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
                let product = app.session.product(app.project, index: index)
                app.alert(.key("Shopping.added"), message: product.0 + " " + product.1)
                app.session.add(app.project, reference: index)
                shopping.refresh()
//                shopping.groceryLast()
            }
            alphaValue = 1
        }
        super.mouseUp(with: with)
    }
}
