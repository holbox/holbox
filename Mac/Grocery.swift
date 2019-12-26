import AppKit

final class Grocery: NSView, NSTextViewDelegate {
    weak var top: NSLayoutConstraint! { didSet { top!.isActive = true } }
    weak var left: NSLayoutConstraint! { didSet { left!.isActive = true } }
    let index: Int
    private(set) weak var emoji: Text!
    private(set) weak var grocery: Text!
    private weak var icon: Image!
    private weak var _delete: Image!
    private weak var shopping: Shopping!
    private weak var width: NSLayoutConstraint!
    private var stock = false
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, shopping: Shopping) {
        self.index = index
        self.shopping = shopping
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.cornerRadius = 6
        layer!.borderWidth = 1
        layer!.borderColor = .clear
        stock = app.session.content(app.project, list: 2, card: index) == "1"
        
        let emoji = Text(.Fix(), Block(), storage: .init())
        emoji.setAccessibilityLabel(.key("Emoji"))
        emoji.font = .regular(30)
        (emoji.layoutManager as! Layout).owns = true
        emoji.string = app.session.content(app.project, list: 0, card: index)
        emoji.alignment = .center
        addSubview(emoji)
        self.emoji = emoji
        
        let grocery = Text(.Fix(), Editable(), storage: Storage())
        grocery.textContainerInset.width = 10
        grocery.textContainerInset.height = 15
        grocery.setAccessibilityLabel(.key("Grocery"))
        grocery.textColor = .white
        grocery.font = .regular(14)
        (grocery.textStorage as! Storage).attributes = [.plain: [.font: NSFont.regular(14), .foregroundColor: NSColor.white],
                                                        .emoji: [.font: NSFont.regular(14)],
                                                        .bold: [.font: NSFont.medium(16), .foregroundColor: NSColor.white],
                                                        .tag: [.font: NSFont.medium(14), .foregroundColor: NSColor.haze()]]
        (grocery.layoutManager as! Layout).owns = true
        (grocery.layoutManager as! Layout).padding = 2
        grocery.string = app.session.content(app.project, list: 1, card: index)
        grocery.tab = true
        grocery.intro = true
        grocery.delegate = self
        grocery.textContainer!.widthTracksTextView = false
        grocery.textContainer!.size.width = 200
        addSubview(grocery)
        self.grocery = grocery
        
        let _delete = Image("clear", tint: .black)
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        let icon = Image("check", tint: .haze())
        addSubview(icon)
        self.icon = icon
        
        icon.centerXAnchor.constraint(equalTo: emoji.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: emoji.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true

        bottomAnchor.constraint(equalTo: grocery.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: grocery.rightAnchor, constant: 20).isActive = true
        
        emoji.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        emoji.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        emoji.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        grocery.topAnchor.constraint(equalTo: topAnchor).isActive = true
        grocery.leftAnchor.constraint(equalTo: emoji.rightAnchor).isActive = true
        width = grocery.widthAnchor.constraint(equalToConstant: 0)
        width.isActive = true
        
        let height = grocery.heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        
        grocery.layoutManager!.ensureLayout(for: grocery.textContainer!)
        resize()
        update()
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.content(app.project, list: 1, card: index, content: grocery.string)
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseEntered(with: NSEvent) {
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .haze(0.2)
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .clear
            _delete.alphaValue = 0
        }
    }
    
    override func rightMouseUp(with: NSEvent) {
        if window!.firstResponder != grocery && bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            grocery.edit.right()
            grocery.setSelectedRange(.init(location: 0, length: grocery.string.utf16.count))
            window!.makeFirstResponder(grocery)
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if with.clickCount == 1 && bounds.contains(convert(with.locationInWindow, from: nil)) {
            if _delete.frame.contains(convert(with.locationInWindow, from: nil)) {
                window!.makeFirstResponder(self)
                app.runModal(for: Delete.Grocery(index))
            } else if window!.firstResponder != grocery {
                if stock {
                    app.alert(.key("Grocery.need"), message: app.session.content(app.project, list: 0, card: index) + " " + app.session.content(app.project, list: 1, card: index))
                    app.session.content(app.project, list: 2, card: index, content: "0")
                    stock = false
                } else {
                    app.alert(.key("Grocery.got"), message: app.session.content(app.project, list: 0, card: index) + " " + app.session.content(app.project, list: 1, card: index))
                    app.session.content(app.project, list: 2, card: index, content: "1")
                    stock = true
                }
                NSAnimationContext.runAnimationGroup {
                    $0.duration = 0.35
                    $0.allowsImplicitAnimation = true
                    update()
                }
            }
        }
    }
    
    private func resize() {
        width.constant = grocery.layoutManager!.usedRect(for: grocery.textContainer!).size.width + 20
    }
    
    private func update() {
        if stock {
            emoji.alphaValue = 0.1
            grocery.alphaValue = 0.4
            icon.isHidden = false
        } else {
            emoji.alphaValue = 1
            grocery.alphaValue = 1
            icon.isHidden = true
        }
    }
}
