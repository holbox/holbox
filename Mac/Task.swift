import AppKit

final class Task: NSView, NSTextViewDelegate {
    let index: Int
    let list: Int
    private(set) weak var text: Text!
    private weak var todo: Todo?
    private weak var icon: Image!
    private weak var _delete: Image!
    private weak var circle: NSView!
    private weak var base: NSView!
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, list: Int, todo: Todo) {
        self.index = index
        self.list = list
        self.todo = todo
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        wantsLayer = true
        
        let content = app.session.content(app.project, list: list, card: index)
        setAccessibilityLabel(content)
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.alphaValue = 0
        base.layer!.cornerRadius = 10
        base.layer!.backgroundColor = NSColor(named: "background")!.cgColor
        addSubview(base)
        self.base = base
        
        let _delete = Image("delete")
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        let circle = NSView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.wantsLayer = true
        circle.layer!.cornerRadius = 13
        circle.layer!.backgroundColor = list == 1 ? NSColor(named: "haze")!.cgColor : NSColor(named: "haze")!.withAlphaComponent(0.2).cgColor
        addSubview(circle)
        self.circle = circle
        
        let icon = Image("check")
        icon.alphaValue = list == 1 ? 1 : 0
        addSubview(icon)
        self.icon = icon
        
        let text = Text(.Fix(), Block())
        text.textContainerInset.width = 10
        text.textContainerInset.height = 10
        text.setAccessibilityElement(false)
        if list == 1 {
            (text.textStorage as! Storage).fonts = [
                .plain: (.systemFont(ofSize: 12, weight: .medium), .init(white: 1, alpha: 0.8)),
                .emoji: (NSFont(name: "Times New Roman", size: 16)!, .white),
                .bold: (.systemFont(ofSize: 14 , weight: .bold), NSColor(named: "haze")!.withAlphaComponent(0.8)),
                .tag: (.systemFont(ofSize: 12, weight: .medium), NSColor(named: "haze")!.withAlphaComponent(0.8))]
            text.alphaValue = 0.7
        } else {
            (text.textStorage as! Storage).fonts = [
                .plain: (.systemFont(ofSize: 16, weight: .medium), .white),
                .emoji: (NSFont(name: "Times New Roman", size: 22)!, .white),
                .bold: (.systemFont(ofSize: 18, weight: .bold), NSColor(named: "haze")!),
                .tag: (.systemFont(ofSize: 16, weight: .medium), NSColor(named: "haze")!)]
        }
        (text.layoutManager as! Layout).owns = true
        (text.layoutManager as! Layout).padding = 1
        text.intro = true
        text.tab = true
        text.string = content
        text.delegate = self
        addSubview(text)
        self.text = text
        
        widthAnchor.constraint(lessThanOrEqualToConstant: 340).isActive = true
        bottomAnchor.constraint(greaterThanOrEqualTo: text.bottomAnchor, constant: 3).isActive = true
        
        let width = widthAnchor.constraint(equalToConstant: 340)
        width.priority = .defaultLow
        width.isActive = true
        
        let height = heightAnchor.constraint(equalToConstant: 30)
        height.priority = .defaultLow
        height.isActive = true
        
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
        
        text.leftAnchor.constraint(equalTo: circle.rightAnchor, constant: -5).isActive = true
        text.rightAnchor.constraint(lessThanOrEqualTo: base.rightAnchor, constant: -5).isActive = true
        text.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.content(app.project, list: list, card: index, content: text.string)
        todo?.tags.refresh()
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
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
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            base.alphaValue = 0
            _delete.alphaValue = 0
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if with.clickCount == 1 {
            if base.frame.contains(convert(with.locationInWindow, from: nil)) {
                if window!.firstResponder != text {
                    app.alert(list == 1 ? .key("Todo.restart") : .key("Todo.completed"), message: app.session.content(app.project, list: list, card: index))
                    app.session.move(app.project, list: list, card: index, destination: list == 1 ? 0 : 1, index: 0)
                    app.main.refresh()
                }
            } else if _delete.frame.contains(convert(with.locationInWindow, from: nil)) {
                window!.makeFirstResponder(superview!)
                _delete.alphaValue = 0
                app.runModal(for: Delete.Card(index, list: list))
            }
        }
        super.mouseUp(with: with)
    }
}
