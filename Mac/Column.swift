import AppKit

final class Column: NSView, NSTextViewDelegate {
    let index: Int
    private weak var kanban: Kanban!
    private weak var text: Text!
    private weak var _delete: Image!
    private weak var width: NSLayoutConstraint!
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int) {
        self.index = index
        self.kanban = kanban
        super.init(frame: .init())
        translatesAutoresizingMaskIntoConstraints = false
        
        let text = Text(.Fix(), Block())
        text.textContainerInset.width = 20
        text.textContainerInset.height = 20
        text.setAccessibilityLabel(.key("Column"))
        text.font = NSFont(name: "Times New Roman", size: 14)
        (text.textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: 14, weight: .bold), NSColor(named: "haze")!),
            .emoji: (NSFont(name: "Times New Roman", size: 14)!, .white),
            .bold: (.systemFont(ofSize: 14, weight: .bold), NSColor(named: "haze")!),
            .tag: (.systemFont(ofSize: 14, weight: .bold), NSColor(named: "haze")!)]
        text.string = app.session.name(app.project, list: index)
        text.textContainer!.maximumNumberOfLines = 1
        text.textContainer!.widthTracksTextView = false
        text.textContainer!.size.width = 300
        addSubview(text)
        self.text = text
        
        let _delete = Image("delete")
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        let min = widthAnchor.constraint(equalToConstant: 0)
        min.priority = .defaultLow
        min.isActive = true
        
        width = text.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        width.isActive = true
        
        let height = heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
        
        rightAnchor.constraint(equalTo: text.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: text.bottomAnchor).isActive = true
        
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        _delete.leftAnchor.constraint(equalTo: leftAnchor, constant: -5).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 35).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        text.delegate = self
        text.layoutManager!.ensureLayout(for: text.textContainer!)
        resize()
        
        track()
    }
    
    override func mouseEntered(with: NSEvent) {
        if window!.firstResponder != self {
            super.mouseEntered(with: with)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.5
                $0.allowsImplicitAnimation = true
                _delete.alphaValue = 1
            }
        }
    }
    
    override func mouseExited(with: NSEvent) {
        if window!.firstResponder != self {
            super.mouseExited(with: with)
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.5
                $0.allowsImplicitAnimation = true
                _delete.alphaValue = 0
            }
        }
    }
    
    override func mouseDown(with: NSEvent) {
        if window!.firstResponder != text && with.clickCount == 2 && bounds.contains(convert(with.locationInWindow, from: nil)) {
            text.click()
        } else {
            super.mouseDown(with: with)
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if window!.firstResponder != self && _delete!.frame.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            window!.makeFirstResponder(superview!)
            if app.session.lists(app.project) > 1 {
                if text.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    app.session.delete(app.project, list: index)
                    kanban.refresh()
                } else {
                    _delete!.alphaValue = 0
                    app.runModal(for: Delete.List(index))
                }
            } else {
                app.alert(.key("Kanban.last"), message: .key("Kanban.need"))
            }
        }
        super.mouseUp(with: with)
    }
    
    func textDidChange(_: Notification) {
        resize()
    }
    
    func textDidBeginEditing(_: Notification) {
        _delete.alphaValue = 0
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.name(app.project, list: index, name: text.string)
        kanban.charts()
    }
    
    func untrack() {
        trackingAreas.forEach(removeTrackingArea(_:))
    }
    
    func track() {
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    private func resize() {
        width.constant = min(max(text.layoutManager!.usedRect(for: text.textContainer!).size.width + 40, 60), 340)
    }
}
