import AppKit

final class Task: Text, NSTextViewDelegate {
    let index: Int
    private weak var todo: Todo!
    private weak var icon: Image!
    private weak var _delete: Image!
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, todo: Todo) {
        self.index = index
        self.todo = todo
        super.init(.Fix(), Block())
        textContainerInset.width = 20
        textContainerInset.height = 20
        wantsLayer = true
        setAccessibilityLabel(.key("Task"))
        font = NSFont(name: "Times New Roman", size: 16)!
        (textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: 16, weight: .medium), .white),
            .emoji: (NSFont(name: "Times New Roman", size: 22)!, .white),
            .bold: (.systemFont(ofSize: 18, weight: .bold), NSColor(named: "haze")!),
            .tag: (.systemFont(ofSize: 16, weight: .medium), NSColor(named: "haze")!)]
        (layoutManager as! Layout).owns = true
        (layoutManager as! Layout).padding = 1
        intro = true
        tab = true
        string = app.session.content(app.project, list: 0, card: index)
        delegate = self
        
        let border = Border.horizontal(0.2)
        addSubview(border)
        
        let _delete = Image("delete")
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 35).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self))
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.content(app.project, list: 0, card: index, content: string)
        todo?.tags.refresh()
    }
    
    override func resetCursorRects() { addCursorRect(bounds, cursor: .pointingHand) }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = NSColor(named: "background")!.cgColor
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.3
            $0.allowsImplicitAnimation = true
            layer!.backgroundColor = .clear
            _delete.alphaValue = 0
        }
    }
    
    override func mouseUp(with: NSEvent) {
        if with.clickCount == 1 {
            if frame.contains(convert(with.locationInWindow, from: nil)) {
                if window!.firstResponder != self {
                    app.alert(.key("Todo.completed"), message: app.session.content(app.project, list: 0, card: index))
                    app.session.move(app.project, list: 0, card: index, destination: 1, index: 0)
                    app.main.refresh()
                } else if _delete.frame.contains(convert(with.locationInWindow, from: nil)) {
                    window!.makeFirstResponder(superview!)
                    _delete.alphaValue = 0
                    app.runModal(for: Delete.Card(index, list: 0))
                }
            }
        }
        super.mouseUp(with: with)
    }
}
