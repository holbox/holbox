import AppKit

final class Task: NSView, NSTextViewDelegate {
    let index: Int
    let list: Int
    private(set) weak var text: Text!
    private weak var _delete: Image!
    private weak var todo: Todo!
    private weak var highlight: NSView!
    private weak var bottom: NSLayoutConstraint!
    
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
        highlight.layer!.backgroundColor = .haze()
        highlight.alphaValue = 0
        addSubview(highlight)
        self.highlight = highlight
        
        let text = Text(.Fix(), Editable(), storage: Storage())
        text.textContainerInset.width = 15
        text.textContainerInset.height = 12
        text.setAccessibilityLabel(.key("Task"))
        text.font = .regular(14)
        (text.textStorage as! Storage).attributes = [.plain: [.font: NSFont.regular(14), .foregroundColor: NSColor.white],
                                                     .emoji: [.font: NSFont.regular(20)],
                                                     .bold: [.font: NSFont.medium(18), .foregroundColor: NSColor.white],
                                                     .tag: [.font: NSFont.medium(12), .foregroundColor: NSColor.haze()]]
        (text.layoutManager as! Layout).owns = true
        (text.layoutManager as! Layout).padding = 1
        text.intro = true
        text.tab = true
        text.string = app.session.content(app.project, list: list, card: index)
        text.delegate = self
        addSubview(text)
        self.text = text
        
        let _delete = Image("clear", tint: .black)
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        if list == 0 {
            text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        } else {
            layer!.backgroundColor = .haze(0.2)
            
            let date = Date(timeIntervalSince1970: TimeInterval(app.session.content(app.project, list: 2, card: index))!)
            let interval: String
            if #available(OSX 10.15, *) {
                interval = RelativeDateTimeFormatter().localizedString(for: date, relativeTo: .init())
            } else {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = Calendar.current.dateComponents([.day], from: date, to: .init()).day! == 0 ? .none : .short
                interval = formatter.string(from: date)
            }
        
            let time = Label(interval, .regular(12), .haze())
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
        
        let width = widthAnchor.constraint(greaterThanOrEqualToConstant: 300)
        width.priority = .defaultLow
        width.isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 60).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.content(app.project, list: list, card: index, content: text.string)
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseEntered(with: NSEvent) {
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            highlight.alphaValue = 0.2
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
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
                if list == 0 {
                    app.session.completed(app.project, index: index)
                } else {
                    app.session.restart(app.project, index: index)
                }
                
                bottom?.isActive = false
                heightAnchor.constraint(equalToConstant: 0).isActive = true
                NSAnimationContext.runAnimationGroup({
                    $0.duration = 0.4
                    $0.allowsImplicitAnimation = true
                    layer!.backgroundColor = .haze(0.9)
                    superview!.layoutSubtreeIfNeeded()
                }) { [weak self] in
                    self?.todo?.refresh()
                }
            }
        }
    }
}
