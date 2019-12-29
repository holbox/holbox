import AppKit

final class Task: NSView, NSTextViewDelegate {
    var index = 0
    var list = 0
    private (set) weak var text: Text!
    private weak var _delete: Image!
    private weak var todo: Todo!
    private weak var time: Label!
    private weak var line: NSView!
    private weak var top: NSLayoutConstraint!
    
    weak var _parent: NSView! {
        didSet {
            top?.isActive = false
            if let scroll = _parent as? Scroll {
                top = topAnchor.constraint(equalTo: scroll.top, constant: 30)
            } else {
                top = topAnchor.constraint(equalTo: _parent.bottomAnchor)
            }
            top.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, list: Int, todo: Todo) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        setAccessibilityLabel(.key("Task"))
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        layer!.cornerRadius = 6
        layer!.borderWidth = 1
        layer!.borderColor = .clear
        self.index = index
        self.list = list
        self.todo = todo
        
        let text = Text(.Fix(), Editable(), storage: Storage())
        text.textContainerInset.width = 10
        text.textContainerInset.height = 12
        text.setAccessibilityElement(false)
        text.font = .regular(14)
        (text.textStorage as! Storage).attributes = [.plain: [.font: NSFont.regular(14), .foregroundColor: NSColor.white],
                                                     .emoji: [.font: NSFont.regular(18)],
                                                     .bold: [.font: NSFont.medium(16), .foregroundColor: NSColor.white],
                                                     .tag: [.font: NSFont.medium(12), .foregroundColor: NSColor.haze()]]
        (text.layoutManager as! Layout).owns = true
        (text.layoutManager as! Layout).padding = 2
        text.intro = true
        text.tab = true
        text.string = app.session.content(app.project, list: list, card: index)
        text.delegate = self
        addSubview(text)
        self.text = text
        
        let _delete = Image("clear")
        _delete.isHidden = true
        _delete.setAccessibilityElement(false)
        _delete.setAccessibilityLabel(.key("Delete"))
        _delete.setAccessibilityRole(.button)
        addSubview(_delete)
        self._delete = _delete
        
        let line = NSView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.wantsLayer = true
        line.layer!.backgroundColor = .haze()
        line.layer!.cornerRadius = 1.5
        addSubview(line)
        self.line = line
        
        let time = Label("", .regular(12), .haze())
        time.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        time.setAccessibilityElement(false)
        addSubview(time)
        self.time = time
        
        widthAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        bottomAnchor.constraint(equalTo: text.bottomAnchor).isActive = true
        
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: _delete.leftAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: time.rightAnchor).isActive = true
        text.widthAnchor.constraint(greaterThanOrEqualToConstant: 90).isActive = true

        let height = text.heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
        
        let width = widthAnchor.constraint(greaterThanOrEqualToConstant: 300)
        width.priority = .defaultLow
        width.isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        line.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        line.rightAnchor.constraint(equalTo: text.leftAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        line.widthAnchor.constraint(equalToConstant: 3).isActive = true
        
        time.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        let timeLeft = time.leftAnchor.constraint(equalTo: leftAnchor, constant: 15)
        timeLeft.priority = .defaultLow
        timeLeft.isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
        
        update()
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.content(app.project, list: list, card: index, content: text.string)
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseEntered(with: NSEvent) {
        layer!.borderColor = .haze()
        _delete.isHidden = false
    }
    
    override func mouseExited(with: NSEvent) {
        layer!.borderColor = .clear
        _delete.isHidden = true
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
                app.runModal(for: Delete.Task(index, list: list))
            } else if window!.firstResponder != text {
                if list == 0 {
                    completed()
                } else {
                    restart()
                }
            }
        }
    }
    
    private func update() {
        time.stringValue = list == 0 ? "" : Date(timeIntervalSince1970: TimeInterval(app.session.content(app.project, list: 2, card: index))!).interval
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            line.alphaValue = list == 0 ? 1 : 0
        }
    }
    
    private func completed() {
        app.alert(.key("Todo.completed"), message: app.session.content(app.project, list: list, card: index))
        app.session.completed(app.project, index: index)
        let tasks = superview!.subviews.map { $0 as! Task }
        tasks.first { $0._parent === self }?._parent = _parent
        if let child = tasks.first(where: { $0.list == 1 && $0.index == 0 }) {
            _parent = child._parent
            child._parent = self
        } else {
            if let _last = todo._last {
                if _last !== self {
                    _parent =  _last
                }
            }
            todo._last = self
        }
        tasks.forEach {
            if $0.list == 1 {
                $0.index += 1
            } else if $0.index > index {
                $0.index -= 1
            }
        }
        index = 0
        list = 1
        reorder()
        todo.charts()
    }
    
    private func restart() {
        app.alert(.key("Todo.restart"), message: app.session.content(app.project, list: list, card: index))
        app.session.restart(app.project, index: index)
        let tasks = superview!.subviews.map { $0 as! Task }
        if let child = tasks.first(where: { $0.list == 0 && $0.index == 0 }) {
            if let next = tasks.first(where: { $0._parent === self }) {
                next._parent = _parent
            } else {
                todo._last = _parent is Task ? (_parent as! Task) : self
            }
            _parent = todo.scroll
            child._parent = self
        } else {
            if todo._last === self {
               todo._last = (_parent as? Task) ?? self
            } else {
                tasks.first { $0._parent === self }?._parent = _parent
            }
            _parent = todo.scroll
            tasks.first(where: { $0.list == 1 && (($0.index == 0 && index > 0) || ($0.index == 1 && index == 0)) })?._parent = self
        }
        tasks.forEach {
            if $0.list == 0 {
                $0.index += 1
            } else if $0.index > index {
                $0.index -= 1
            }
        }
        index = 0
        list = 0
        reorder()
        todo.charts()
    }
    
    private func reorder() {
        update()
        NSAnimationContext.runAnimationGroup ({
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .haze(0.3)
            superview!.layoutSubtreeIfNeeded()
        }) { [weak self] in
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.25
                $0.allowsImplicitAnimation = true
                self?.layer!.backgroundColor = .clear
            }
        }
    }
}
