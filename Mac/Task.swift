import AppKit

final class Task: NSView, NSTextViewDelegate {
    let index: Int
    let list: Int
    private(set) weak var text: Text!
    private weak var icon: Image!
    private weak var _delete: Button!
    private weak var circle: NSView!
    private weak var base: NSView!
    private var highlighted = false { didSet { update() } }
    private var active: Bool { (list == 1 && !highlighted) || (list == 0 && highlighted) }
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, list: Int) {
        self.index = index
        self.list = list
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        wantsLayer = true
        
        let content = app.session.content(app.project!, list: list, card: index)
        setAccessibilityLabel(content)
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.alphaValue = 0
        base.layer!.cornerRadius = 10
        base.layer!.backgroundColor = NSColor(named: "background")!.cgColor
        addSubview(base)
        self.base = base
        
        let _delete = Button("delete", target: self, action: #selector(delete))
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        let circle = NSView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.wantsLayer = true
        circle.layer!.cornerRadius = 13
        addSubview(circle)
        self.circle = circle
        
        let icon = Image("check")
        addSubview(icon)
        self.icon = icon
        
        let text = Text(.Fixed(), Block())
        text.setAccessibilityElement(false)
        (text.textStorage as! Storage).fonts = [.plain: (.systemFont(ofSize: list == 1 ? 14 : 16, weight: .medium), list == 1 ? NSColor(named: "haze")!.withAlphaComponent(0.8) : .white),
                                               .emoji: (NSFont(name: "Times New Roman", size: list == 1 ? 20 : 22)!, list == 1 ? NSColor(named: "haze")!.withAlphaComponent(0.8) : .white),
                                               .bold: (.systemFont(ofSize: list == 1 ? 16 : 18, weight: .bold), list == 1 ? NSColor(named: "haze")!.withAlphaComponent(0.8) : NSColor(named: "haze")!),
                                               .tag: (.systemFont(ofSize: list == 1 ? 14 : 16, weight: .medium), list == 1 ? NSColor(named: "haze")!.withAlphaComponent(0.8) : NSColor(named: "haze")!)]
        (text.layoutManager as! Layout).owns = true
        text.intro = true
        text.string = content
        text.delegate = self
        base.addSubview(text)
        addSubview(text)
        self.text = text
        
        widthAnchor.constraint(lessThanOrEqualToConstant: 500).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: text.bottomAnchor).isActive = true
        
        let width = widthAnchor.constraint(equalToConstant: 500)
        width.priority = .defaultLow
        width.isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: rightAnchor, constant: -32).isActive = true
        base.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        _delete.leftAnchor.constraint(equalTo: base.rightAnchor, constant: 2).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        circle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circle.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 26).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        icon.widthAnchor.constraint(equalToConstant: 14).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 14).isActive = true
        icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
        
        text.leftAnchor.constraint(equalTo: circle.rightAnchor).isActive = true
        text.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -5).isActive = true
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        update()
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseDown(with: NSEvent) {
        if window!.firstResponder != text && base.bounds.contains(convert(with.locationInWindow, from: nil)) {
            highlighted = true
            super.mouseDown(with: with)
        }
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            base.alphaValue = 1
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            base.alphaValue = 0
            _delete.alphaValue = 0
        }) { [weak self] in
            self?.highlighted = false
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if window!.firstResponder != text && base.bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            app.alert(list == 1 ? .key("Todo.restart") : .key("Todo.completed"), message: app.session.content(app.project!, list: list, card: index))
            app.session.move(app.project!, list: list, card: index, destination: list == 1 ? 0 : 1, index: 0)
            app.main.refresh()
        }
        highlighted = false
        super.mouseUp(with: with)
    }
    
    override func rightMouseUp(with: NSEvent) {
        if bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            text.edit.click()
            window!.makeFirstResponder(text)
        }
        super.rightMouseUp(with: with)
    }
    
    private func update() {
        icon.alphaValue = active ? 1 : 0
        circle.layer!.backgroundColor = active ? NSColor(named: "haze")!.cgColor : NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
    }
    
    @objc private func delete() {
        window!.makeFirstResponder(self)
        _delete.alphaValue = 0
        app.runModal(for: Delete.Card(index, list: list))
    }
}
