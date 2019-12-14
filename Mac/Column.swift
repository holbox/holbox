import AppKit

final class Column: Text, NSTextViewDelegate {
    let index: Int
    private weak var kanban: Kanban!
    private weak var _delete: Image!
    private weak var width: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int) {
        self.index = index
        self.kanban = kanban
        super.init(.Fix(), Block())
        textContainerInset.width = 20
        textContainerInset.height = 20
        setAccessibilityLabel(.key("Column"))
        font = NSFont(name: "Times New Roman", size: 20)
        (textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: 20, weight: .heavy), NSColor(named: "haze")!),
            .emoji: (NSFont(name: "Times New Roman", size: 22)!, .white),
            .bold: (.systemFont(ofSize: 20, weight: .heavy), NSColor(named: "haze")!),
            .tag: (.systemFont(ofSize: 20, weight: .heavy), NSColor(named: "haze")!)]
        string = app.session.name(app.project, list: index)
        textContainer!.maximumNumberOfLines = 1
        textContainer!.widthTracksTextView = false
        textContainer!.size.width = 300
        
        let _delete = Image("delete")
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        let min = widthAnchor.constraint(equalToConstant: 0)
        min.priority = .defaultLow
        min.isActive = true
        
        width = widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        width.isActive = true
        
        let height = heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
        
        _delete.leftAnchor.constraint(equalTo: leftAnchor, constant: -5).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 35).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        delegate = self
        layoutManager!.ensureLayout(for: textContainer!)
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
    
    override func mouseUp(with: NSEvent) {
        if window!.firstResponder != self && _delete!.frame.contains(convert(with.locationInWindow, from: nil)) && with.clickCount == 1 {
            window!.makeFirstResponder(superview!)
            if app.session.lists(app.project) > 1 {
                if string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
        app.session.name(app.project, list: index, name: string)
        kanban.charts()
    }
    
    func untrack() {
        trackingAreas.forEach(removeTrackingArea(_:))
    }
    
    func track() {
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    private func resize() {
        width.constant = min(max(layoutManager!.usedRect(for: textContainer!).size.width + 40, 60), 340)
    }
}
