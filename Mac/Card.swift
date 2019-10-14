import AppKit

final class Card: NSView, NSTextViewDelegate {
    let index: Int
    private weak var content: Text!
    private let column: Int
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int, column: Int) {
        self.index = index
        self.column = column
        super.init(frame: .zero)
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        translatesAutoresizingMaskIntoConstraints = false
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
        
        addSubview(content)
        
        rightAnchor.constraint(equalTo: content.rightAnchor, constant: 10).isActive = true
        bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: 10).isActive = true
        content.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        content.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        content.didChangeText()
        content.delegate = self
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
}
