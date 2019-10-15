import AppKit

final class Card: NSView, NSTextViewDelegate {
    let index: Int
    let column: Int
    private weak var content: Text!
    private weak var base: NSView!
    private weak var _delete: Button!
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, column: Int) {
        self.index = index
        self.column = column
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        base.layer!.cornerRadius = 8
        base.layer!.borderWidth = 1
        base.layer!.borderColor = .black
        addSubview(base)
        self.base = base
        
        let content = Text()
        content.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
        content.string = app.session.content(app.project, list: column, card: index)
        content.tab = true
        content.intro = true
        content.standby = 0.8
        content.textContainer!.size.width = 360
        content.textContainer!.size.height = 5000
        addSubview(content)
        self.content = content
        
        let _delete = Button("delete", target: self, action: #selector(delete))
        _delete.alphaValue = 0
        addSubview(_delete)
        self._delete = _delete
        
        rightAnchor.constraint(equalTo: base.rightAnchor, constant: 40).isActive = true
        bottomAnchor.constraint(equalTo: base.bottomAnchor).isActive = true
        
        base.topAnchor.constraint(equalTo: topAnchor).isActive = true
        base.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        base.rightAnchor.constraint(equalTo: content.rightAnchor, constant: 10).isActive = true
        base.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 10).isActive = true
        
        _delete.leftAnchor.constraint(equalTo: base.rightAnchor, constant: 10).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        content.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        content.didChangeText()
        content.delegate = self
        
        addTrackingArea(.init(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self, userInfo: nil))
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    func textDidChange(_: Notification) {
        app.session.content(app.project, list: column, card: index, content: content.string)
    }
    
    func textDidBeginEditing(_: Notification) {
        base.layer!.borderColor = .haze
        base.layer!.borderWidth = 2
    }
    
    func textDidEndEditing(_: Notification) {
        base.layer!.borderColor = .black
        base.layer!.borderWidth = 1
    }
    
    func edit() {
        content.edit = true
        window!.makeFirstResponder(content)
    }
    
    override func mouseEntered(with: NSEvent) {
        super.mouseEntered(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            _delete.alphaValue = 1
        }
    }
    
    override func mouseExited(with: NSEvent) {
        super.mouseExited(with: with)
        NSAnimationContext.runAnimationGroup {
            $0.duration = 0.5
            $0.allowsImplicitAnimation = true
            _delete.alphaValue = 0
        }
    }
    
    @objc private func delete() {
        _delete.alphaValue = 0
        app.runModal(for: Delete.Card(index, list: column))
    }
}
