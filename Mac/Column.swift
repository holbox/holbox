import AppKit

final class Column: NSView, NSTextViewDelegate {
    private let index: Int
    private weak var name: Text!
    
    required init?(coder: NSCoder) { nil }
    init(_ index: Int) {
        self.index = index
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let name = Text(.Expand(400, 100), Block())
        name.textContainerInset.width = 10
        name.textContainerInset.height = 10
        name.setAccessibilityLabel(.key("Column"))
        (name.textStorage as! Storage).fonts = [
            .plain: (.systemFont(ofSize: 20, weight: .heavy), NSColor(named: "haze")!),
            .emoji: (NSFont(name: "Times New Roman", size: 22)!, .white),
            .bold: (.systemFont(ofSize: 20, weight: .heavy), NSColor(named: "haze")!),
            .tag: (.systemFont(ofSize: 20, weight: .heavy), NSColor(named: "haze")!)]
        name.string = app.session.name(app.project!, list: index)
        name.textContainer!.maximumNumberOfLines = 1
        addSubview(name)
        self.name = name
        
        let width = widthAnchor.constraint(equalToConstant: 0)
        width.priority = .defaultLow
        width.isActive = true
        
        rightAnchor.constraint(greaterThanOrEqualTo: name.rightAnchor, constant: 40).isActive = true
        bottomAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor).isActive = true
        name.didChangeText()
        name.delegate = self
    }
    
    func textDidEndEditing(_: Notification) {
        app.session.name(app.project!, list: index, name: name.string)
    }
}
