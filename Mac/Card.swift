import AppKit

final class Card: NSView, NSTextViewDelegate {
    let index: Int
    let column: Int
    private weak var content: Text!
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, column: Int) {
        self.index = index
        self.column = column
        super.init(frame: .zero)
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        translatesAutoresizingMaskIntoConstraints = false
        
        let base = NSView
        wantsLayer = true
        layer!.cornerRadius = 8
        layer!.borderWidth = 1
        layer!.borderColor = .black
        
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
        addSubview(_delete)
        
        _delete.leftAnchor.constraint(equalTo: rightAnchor, constant: 10).isActive = true
        _delete.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        _delete.widthAnchor.constraint(equalToConstant: 30).isActive = true
        _delete.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        rightAnchor.constraint(equalTo: content.rightAnchor, constant: 10).isActive = true
        bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 10).isActive = true
        content.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        content.didChangeText()
        content.delegate = self
        
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect], owner: self, userInfo: nil))
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    func textDidChange(_: Notification) {
        app.session.content(app.project, list: column, card: index, content: content.string)
    }
    
    func textDidBeginEditing(_: Notification) {
        layer!.borderColor = .haze
        layer!.borderWidth = 2
    }
    
    func textDidEndEditing(_: Notification) {
        layer!.borderColor = .black
        layer!.borderWidth = 1
    }
    
    func edit() {
        content.edit = true
        window!.makeFirstResponder(content)
    }
    
    override func mouseEntered(with: NSEvent) {
        print("enter")
    }
    
    override func mouseExited(with: NSEvent) {
        print("exit")
    }
    
    @objc private func delete() {
        print("delete")
    }
}
