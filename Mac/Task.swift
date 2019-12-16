import AppKit

final class Task: NSView, NSTextViewDelegate {
    let index: Int
    private(set) weak var text: Text!
    private weak var todo: Todo!
    private weak var icon: Image!
    private weak var _delete: Image!
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, todo: Todo) {
        self.index = index
        self.todo = todo
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        let text = Text(.Fix(), Block())
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
        text.string = app.session.content(app.project, list: 0, card: index)
        text.delegate = self
        addSubview(text)
        self.text = text
        
        let _delete = Image("clear")
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        bottomAnchor.constraint(equalTo: text.bottomAnchor).isActive = true
        
        text.topAnchor.constraint(equalTo: topAnchor).isActive = true
        text.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        text.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        
        let width = widthAnchor.constraint(equalToConstant: 400)
        width.priority = .defaultLow
        width.isActive = true
        
        let height = text.heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
        
        _delete.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 50).isActive = true
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
        print(convert(with.locationInWindow, from: nil))
//        if with.clickCount == 1 && frame.contains(convert(with.locationInWindow, from: nil)) {
//            if window!.firstResponder != self {
//                app.alert(.key("Todo.completed"), message: app.session.content(app.project, list: 0, card: index))
//                app.session.move(app.project, list: 0, card: index, destination: 1, index: 0)
//                app.main.refresh()
//            } else if _delete.frame.contains(convert(with.locationInWindow, from: nil)) {
//                window!.makeFirstResponder(superview!)
//                _delete.alphaValue = 0
//                app.runModal(for: Delete.Card(index, list: 0))
//            }
//        }
        super.mouseUp(with: with)
    }
}
