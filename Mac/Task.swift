import AppKit

final class Task: NSView, NSTextViewDelegate {
    let index: Int
    let list: Int
    private(set) weak var text: Text!
    private weak var todo: Todo!
    private weak var icon: Image!
    private weak var highlight: NSView!
    private weak var _delete: Image!
    private weak var bottom: NSLayoutConstraint!
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, list: Int, todo: Todo) {
        self.index = index
        self.list = list
        self.todo = todo
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let highlight = NSView()
        highlight.translatesAutoresizingMaskIntoConstraints = false
        highlight.wantsLayer = true
        highlight.layer!.backgroundColor = NSColor(named: "haze")!.cgColor
        highlight.alphaValue = 0
        addSubview(highlight)
        self.highlight = highlight
        
        let text = Text(.Fix(), Editable())
        text.textContainerInset.width = 15
        text.textContainerInset.height = 12
        text.setAccessibilityLabel(.key("Task"))
        text.font = NSFont(name: "Times New Roman", size: 14)!
        (text.textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: 14, weight: .regular), .white),
            .emoji: (NSFont(name: "Times New Roman", size: 18)!, .white),
            .bold: (.systemFont(ofSize: 16, weight: .bold), NSColor(named: "haze")!),
            .tag: (.systemFont(ofSize: 14, weight: .medium), NSColor(named: "haze")!)]
        (text.layoutManager as! Layout).owns = true
        (text.layoutManager as! Layout).padding = 1
        text.intro = true
        text.tab = true
        text.string = app.session.content(app.project, list: list, card: index)
        text.delegate = self
        addSubview(text)
        self.text = text
        
        let _delete = Image("clear")
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        if list == 0 {
            text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        } else {
            layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.3).cgColor
            
            let interval: String
                
            if #available(OSX 10.15, *) {
                interval = RelativeDateTimeFormatter().localizedString(for: Date(), relativeTo: .init())
            } else {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = Calendar.current.dateComponents([.day], from: Date(), to: .init()).day! == 0 ? .none : .short
                interval = formatter.string(from: Date())
            }
        
            let time = Label(interval, 12, .regular, NSColor(named: "haze")!)
            addSubview(time)
            
            time.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
            time.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            time.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -40).isActive = true
            
            text.topAnchor.constraint(equalTo: time.bottomAnchor, constant: -5).isActive = true
        }
        
        bottom = bottomAnchor.constraint(equalTo: text.bottomAnchor)
        bottom.isActive = true
        
        highlight.topAnchor.constraint(equalTo: topAnchor).isActive = true
        highlight.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        highlight.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        highlight.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor, constant: -50).isActive = true
        
        let height = text.heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.content(app.project, list: 0, card: index, content: text.string)
        todo?.tags.refresh()
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            highlight.alphaValue = 0.2
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            highlight.alphaValue = 0
            _delete.alphaValue = 0
        }
    }
    
    override func rightMouseUp(with: NSEvent) {
        if window!.firstResponder != text && bounds.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            text.edit.right()
            text.setSelectedRange(.init(location: 0, length: text.string.utf16.count))
            window!.makeFirstResponder(text)
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if with.clickCount == 1 && bounds.contains(convert(with.locationInWindow, from: nil)) {
            if _delete.frame.contains(convert(with.locationInWindow, from: nil)) {
                window!.makeFirstResponder(self)
                app.runModal(for: Delete.Card(index, list: list))
            } else if window!.firstResponder != text {
                app.alert(list == 0 ? .key("Todo.completed") : .key("Todo.restart"), message: app.session.content(app.project, list: list, card: index))
                app.session.move(app.project, list: list, card: index, destination: list == 0 ? 1 : 0, index:
                    app.session.cards(app.project, list: list == 0 ? 1 : 0))
                
                bottom?.isActive = false
                heightAnchor.constraint(equalToConstant: 0).isActive = true
                NSAnimationContext.runAnimationGroup({
                    $0.duration = 0.6
                    $0.allowsImplicitAnimation = true
                    layer!.backgroundColor = NSColor(named: "haze")!.withAlphaComponent(0.9).cgColor
                    superview!.layoutSubtreeIfNeeded()
                }) { [weak self] in
                    self?.todo?.refresh()
                }
            }
        }
    }
}
