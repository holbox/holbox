import AppKit

final class Column: Text, NSTextViewDelegate {
    let index: Int
    private weak var kanban: Kanban!
    private weak var width: NSLayoutConstraint!
    
    required init?(coder: NSCoder) { nil }
    init(_ kanban: Kanban, index: Int) {
        self.index = index
        self.kanban = kanban
        super.init(.Fix(), Block())
        textContainerInset.width = 10
        textContainerInset.height = 10
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
        
        let min = widthAnchor.constraint(equalToConstant: 0)
        min.priority = .defaultLow
        min.isActive = true
        
        width = widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
        width.isActive = true
        
        let height = heightAnchor.constraint(equalToConstant: 0)
        height.priority = .defaultLow
        height.isActive = true
        
        delegate = self
        layoutManager!.ensureLayout(for: textContainer!)
        resize()
    }
    
    func textDidChange(_: Notification) {
        resize()
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.name(app.project, list: index, name: string)
        kanban.charts()
    }
    
    private func resize() {
        width.constant = min(max(layoutManager!.usedRect(for: textContainer!).size.width + 20, 60), 320)
    }
}
