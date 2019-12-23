import AppKit

final class Task: NSView, NSTextViewDelegate {
    let index: Int
    let list: Int
    private (set) weak var text: Text!
    private weak var _delete: Image!
    private weak var todo: Todo!
    private weak var time: Label!
    private weak var line: NSView!
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, list: Int, todo: Todo) {
        self.index = index
        self.list = list
        self.todo = todo
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.cornerRadius = 6
        layer!.borderWidth = 1
        layer!.borderColor = .clear
        
        let text = Text(.Fix(), Editable(), storage: Storage())
        text.textContainerInset.width = 10
        text.textContainerInset.height = 12
        text.setAccessibilityLabel(.key("Task"))
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
                app.alert(list == 0 ? .key("Todo.completed") : .key("Todo.restart"), message: app.session.content(app.project, list: list, card: index))
                if list == 0 {
                    app.session.completed(app.project, index: index)
                } else {
                    app.session.restart(app.project, index: index)
                }
                todo.refresh()
            }
        }
    }
    
    private func update() {
        if list == 0 {
            line.isHidden = false
            time.stringValue = ""
        } else {
            line.isHidden = true
            time.stringValue = Date(timeIntervalSince1970: TimeInterval(app.session.content(app.project, list: 2, card: index))!).interval
        }
    }
}
