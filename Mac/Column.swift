import AppKit

final class Column: NSView, NSTextViewDelegate {
    let index: Int
    private weak var kanban: Kanban!
    private weak var text: Text!
    private weak var _delete: Image!
    private weak var width: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int) {
        self.index = index
        self.kanban = kanban
        super.init(frame: .init())
        translatesAutoresizingMaskIntoConstraints = false
        setAccessibilityLabel(.key("Column"))
        setAccessibilityElement(true)
        
        let text = Text(.Fix(), Block(), storage: .init())
        text.textContainerInset.width = 20
        text.textContainerInset.height = 20
        text.setAccessibilityElement(false)
        text.font = .bold(22)
        text.textColor = .haze(0.6)
        text.string = app.session.name(app.project, list: index)
        text.textContainer!.maximumNumberOfLines = 1
        (text.layoutManager as! Layout).padding = 2
        text.textContainer!.widthTracksTextView = false
        text.textContainer!.size.width = 300
        addSubview(text)
        self.text = text
        
        let _delete = Image("clear")
        _delete.setAccessibilityElement(true)
        _delete.setAccessibilityLabel(.key("Delete"))
        _delete.setAccessibilityRole(.button)
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
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 35).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        text.delegate = self
        text.layoutManager!.ensureLayout(for: text.textContainer!)
        
        resize()
        track()
    }
    
    override func mouseEntered(with: NSEvent) {
        if window!.firstResponder != self {
            NSAnimationContext.runAnimationGroup {
                $0.duration = 0.5
                $0.allowsImplicitAnimation = true
                _delete.alphaValue = 1
            }
        }
    }
    
    override func mouseExited(with: NSEvent) {
        if window!.firstResponder != self {
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
        if window!.firstResponder != text && _delete!.frame.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            window!.makeFirstResponder(self)
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
        } else {
            super.mouseUp(with: with)
        }
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
